{ config, pkgs, lib, ... }:
{
  # ── iGPU for OBS QSV encoding ─────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  # ── Libvirt virtualisation stack ──────────────────────────────────────────
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemu = {
      package = pkgs.qemu_full;
      swtpm.enable = true;
      runAsRoot = false;
      # Remove verbatimConfig entirely — it produces duplicate entries
    };
  };

  networking.firewall.interfaces."virbr0" = {
    allowedTCPPorts = [ 445 ];
    allowedUDPPorts = [ 4010 ];
  };

  services.samba = {
    enable = true;
    openFirewall = false;
    settings = {
      global = {
        "server min protocol" = "SMB2";
        "server signing" = "mandatory";
        "interfaces" = "lo virbr0";
        "bind interfaces only" = "yes";
        "hosts allow" = "192.168.122. 127.";
        "hosts deny" = "0.0.0.0/0";
      };
      "vm-share" = {
        path = "/home/ca/Downloads/vm-share";
        browseable = "yes";
        writable = "yes";
        "guest ok" = "no";
        "valid users" = "ca";
        "force user" = "ca";
        "force group" = "users";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

# Write directly to /etc/libvirt/ which virtqemud reads with highest priority
  environment.etc."libvirt/virtqemud.conf".text = ''
    user = "ca"
    group = "libvirtd"
    remember_owner = 0
    cgroup_device_acl = [
      "/dev/kvmfr0",
      "/dev/shm/looking-glass",
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/rtc", "/dev/hpet"
    ]
  '';

# Also fix /var/lib/libvirt/qemu.conf which controls the QEMU driver user
# We need to overwrite it to remove the duplicate qemu-libvirtd entries
  systemd.services.fix-libvirt-qemu-conf = {
    description = "Fix libvirt qemu.conf user settings";
    before = [ "virtqemud.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "fix-qemu-conf" ''
        cat > /var/lib/libvirt/qemu.conf << 'EOF'
  user = "ca"
  group = "libvirtd"
  remember_owner = 0
  cgroup_device_acl = [
    "/dev/kvmfr0",
    "/dev/shm/looking-glass",
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/rtc", "/dev/hpet"
  ]
  EOF
        chmod 0444 /var/lib/libvirt/qemu.conf
      '';
    };
  };

  environment.variables = {
    LIBVIRT_DEFAULT_URI = "qemu:///system";
    EDITOR = "nvim";
  };

  # ── Boot: VFIO, IOMMU, CPU isolation ──────────────────────────────────────
  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "amdgpu"        # Host display — loads after VFIO
      "i915"          # iGPU for OBS — loads after VFIO
    ];

    kernelModules = [ "kvm_intel" "kvmfr" "msr" ];

    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"

      # VFIO: claim GTX 1660 Ti before any display driver
      "vfio-pci.ids=10de:2182,10de:1aeb,10de:1aec,10de:1aed"

      # KVM MSR handling
      "kvm.ignore_msrs=1"

      # Hugepages: 16 GB locked for VM
      "hugepagesz=2M"
      "hugepages=8192"
      "transparent_hugepage=never"

      # Keep default host IRQ placement off the VM-designated CPUs.
      "irqaffinity=0-3,8-11"

      # CPU isolation: physical cores 4-7 + HT siblings 12-15 for VM
      "isolcpus=domain,managed_irq,4-7,12-15"
      "nohz_full=4-7,12-15"
      "rcu_nocbs=4-7,12-15"
      "rcu_nocb_poll"       # Reduces RCU wakeup latency on isolated cores

      # Xanmod-specific: preempt is set in base.nix as 'full'
      # which is correct for Xanmod — do not override here
    ];

    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];

    extraModprobeConfig = ''
      options vfio-pci ids=10de:2182,10de:1aeb,10de:1aec,10de:1aed
      options kvm ignore_msrs=1 report_ignored_msrs=0
      options kvmfr static_size_mb=128
    '';
  };

  # ── Disable legacy monolithic daemon (TPM credential bug) ─────────────────
  systemd.services.libvirtd = {
    enable = false;
    serviceConfig.LoadCredentialEncrypted = lib.mkForce [];
  };
  systemd.sockets.libvirtd       = { enable = false; };
  systemd.sockets."libvirtd-ro"  = { enable = false; };
  systemd.sockets."libvirtd-admin" = { enable = false; };

  # ── Modular libvirt daemons ────────────────────────────────────────────────
  systemd.sockets = {
    virtqemud    = { enable = true; wantedBy = [ "sockets.target" ]; };
    virtsecretd  = { enable = true; wantedBy = [ "sockets.target" ]; };
    virtnetworkd = { enable = true; wantedBy = [ "sockets.target" ]; };
    virtstoraged = { enable = true; wantedBy = [ "sockets.target" ]; };
    virtnodedevd = { enable = true; wantedBy = [ "sockets.target" ]; };
    virtinterfaced = { enable = true; wantedBy = [ "sockets.target" ]; };
  };

  systemd.services = {
    # virtqemud: socket-activated, PATH-injected so swtpm/dmidecode are visible
    virtqemud = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "virtqemud.socket" ];
      after    = [ "virtqemud.socket" "network.target" ];
      serviceConfig.EnvironmentFile = pkgs.writeText "virtqemud-env" ''
        VIRTQEMUD_ARGS=--timeout 120
        PATH=${pkgs.swtpm}/bin:${pkgs.qemu_full}/bin:${pkgs.dmidecode}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.systemd}/bin
      '';
    };
  
# Make iptables visible to virtnetworkd
    virtnetworkd = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      serviceConfig.EnvironmentFile = pkgs.writeText "virtnetworkd-env" ''
        VIRTNETWORKD_ARGS=--timeout 120
        PATH=${pkgs.iptables}/sbin:${pkgs.iproute2}/sbin:${pkgs.iproute2}/bin:${pkgs.dnsmasq}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.systemd}/bin
      '';
    };

    # Remaining modular daemons: socket-activated, no special config needed
    virtsecretd   = { enable = true; wantedBy = [ "multi-user.target" ]; };
    virtstoraged  = { enable = true; wantedBy = [ "multi-user.target" ]; };
    virtnodedevd  = { enable = true; wantedBy = [ "multi-user.target" ]; };
    virtinterfaced = { enable = true; wantedBy = [ "multi-user.target" ]; };

    # Looking Glass shared memory — runs before VM starts
    prepare-looking-glass = {
      description = "Prepare Looking Glass shared memory";
      before   = [ "virtqemud.service" ];   # fixed: was referencing disabled libvirtd
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "prepare-lg" ''
          rm -f /dev/shm/looking-glass
          ${pkgs.coreutils}/bin/truncate -s 128M /dev/shm/looking-glass
          chown ca:libvirtd /dev/shm/looking-glass
          chmod 0660 /dev/shm/looking-glass
        '';
      };
    };

    set-cpu-performance-policy = {
      description = "Pin nNix CPU power policy to performance";
      after = [ "systemd-modules-load.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.boot.kernelPackages.cpupower}/bin/cpupower set --epp performance --perf-bias 0";
      };
    };
  };

  # Host-side Scream receiver for the trading VM audio stream over libvirt.
  systemd.user.services.scream = {
    description = "Scream audio receiver";
    after = [ "pipewire.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.scream}/bin/scream -o pulse -u -p 4010";
      Restart = "always";
      RestartSec = "3";
    };
  };

  # ── Stable emulator symlink (survives QEMU updates) ───────────────────────
  systemd.tmpfiles.rules = [
    "d /home/ca/Downloads/vm-share 0770 ca libvirtd -"
    "d /run/libvirt/nix-emulators 0755 root root -"
    "L /run/libvirt/nix-emulators/qemu-system-x86_64 - - - - ${pkgs.qemu_full}/bin/qemu-system-x86_64"
    "d /run/libvirt/nix-ovmf 0755 root root -"
    "L /run/libvirt/nix-ovmf/edk2-x86_64-secure-code.fd - - - - ${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd"
    "L /run/libvirt/nix-ovmf/edk2-i386-vars.fd - - - - ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd" 
  ];

  # ── Device permissions ────────────────────────────────────────────────────
  services.udev.extraRules = ''
    SUBSYSTEM=="vfio",  OWNER="root", GROUP="libvirtd", MODE="0660"
    SUBSYSTEM=="kvmfr", GROUP="libvirtd", MODE="0660"
  '';

  # ── CPU governor: performance on all cores ────────────────────────────────
  # (also set in base.nix — this mkForce ensures it wins on this host)
  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  # ── IRQ affinity: keep VM-core IRQs off isolated cores ───────────────────
  # Prevents hardware interrupts from landing on cores 4-7,12-15
  systemd.services.irqbalance = {
    enable = true;
    serviceConfig.ExecStart = lib.mkForce [
      ""
      (pkgs.writeShellScript "irqbalance-vm-cores" ''
        export IRQBALANCE_BANNED_CPULIST=4-7,12-15
        exec ${config.services.irqbalance.package}/bin/irqbalance --journal
      '')
    ];
  };

  # ── User permissions ──────────────────────────────────────────────────────
  users.users.ca.extraGroups = [
    "libvirtd" "kvm" "input" "render" "video"
  ];

  # ── System packages ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    (obs-studio.override {
      ffmpeg = ffmpeg_6-full;
    })
    swtpm
    scream
    dmidecode
    irqbalance
    iptables
    dnsmasq # virtnetworkd needs it for default NAT network DHCP
    virt-manager
    virt-viewer
    looking-glass-client
    spice-gtk
    virtio-win
    pciutils
    usbutils
    cpufrequtils
  ];
}
