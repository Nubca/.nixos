{ config, pkgs, lib, ... }:

{
# Run Stream off iGPU via OBS and "Hardware (QSV)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell+ (including your i9)
      intel-vaapi-driver        # Legacy support
      libvdpau-va-gl
    ];
  };

  # 1. Core Virtualization Services
  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      swtpm.enable = true; # Required for Windows 11
      vhostUserPackages = [ pkgs.virtiofsd ];
      verbatimConfig = ''
        # user = "ca"
        # group = "libvirtd"
        remember_owner = 0
        # namespaces = [ "mount" ]
        cgroup_device_acl = [
          "/dev/kvmfr0",
          "/dev/shm/looking-glass",
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/rtc", "/dev/hpet"
        ]
      '';
    };
  };

  # This ensures the 'default' network is always active
  # networking.bridge.enable = true;

  # hardware.ksm.enable = true; # Reduces Ram via Shared Pages
  # 2. Kernel & Module Logic
  # We use lib.mkForce to ensure this isn't overridden by other modules
  boot.extraModprobeConfig = lib.mkForce ''
    options kvmfr static_size_mb=128
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';
  # 2. Kernel & Low-Latency Optimizations
  # Note: If using AMD, change "intel_iommu=on" to "amd_iommu=on"
  boot.kernelParams = [
    "intel_iommu=on"
    "intel_pstate=passive"
    "amd_iommu=on"
    "iommu=pt"
    "hugepagesz=2M"
    "hugepages=8192"   # Reserves 8GB RAM for the VM
    "transparent_hugepage=madvise"
    "vfio-pci.ids=10de:2182,10de:1aeb,10de:1aec,10de:1aed"   # These are your specific 1660 Ti IDs
    "isolcpus=4-7,12-15" 
    "nohz_full=4-7,12-15" 
    "rcu_nocbs=4-7,12-15"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];

  # Set permissions so your user 'ca' can access the device
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="ca", GROUP="libvirtd", MODE="0660"
  '';
  boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "kvm_intel" "kvmfr" ];
  boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "amdgpu" "i915" ];

  # Set CPU to performance mode for consistent order execution speed
  powerManagement.cpuFreqGovernor = "performance";

  # Setup the shared memory file for Looking Glass
  systemd.services.prepare-looking-glass = {
    description = "Set Looking Glass shared memory size";
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'rm -f /dev/shm/looking-glass && ${pkgs.coreutils}/bin/truncate -s 128M /dev/shm/looking-glass && chown ca:libvirtd /dev/shm/looking-glass && chmod 0666 /dev/shm/looking-glass'";
    };
  };


  # User Permissions
  users.users.ca.extraGroups = [ "libvirtd" "kvm" "input" "render" "video" ];

  # Required System Packages
  environment.systemPackages = with pkgs; [
    (obs-studio.override {
      ffmpeg = ffmpeg_6-full; # Ensures all codecs are available
    })
    virt-manager
    virt-viewer
    looking-glass-client
    spice-gtk
    virtio-win # Windows drivers for high-speed Disk/NIC
    virtiofsd
  ];
}
