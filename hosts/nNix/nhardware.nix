{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    # swraid = {
    #   enable = true;
    #   mdadmConf = ''
    #     MAILADDR root@localhost
    #     ARRAY /dev/md127 level=raid1 num-devices=2 metadata=1.2 name=raid1 UUID=28328f99:0625df97:72836534:1327af59 devices=/dev/sda1,/dev/sdb1
    #   '';
    # };
    # resumeDevice = lib.mkForce "/dev/disk/by-uuid/28328f99:0625df97:72836534:1327af59";
  # Set kernel parameters for hibernation
    kernelParams = [
      # "resume_offset=34816"
      "nvidia-drm.modeset=1"
    ];
    kernelModules = [
      "kvm-intel"
    ];
    extraModulePackages = [
    ];
    # kernel.sysctl = { # Limit RAID resync speed so it doesn’t kill the system
    #   "dev.raid.speed_limit_min" = 1000;
    #   "dev.raid.speed_limit_max" = 100000;
    # };
  };

# hardware.mdadm.arrays = {
#     data = {
#       level = 1;
#       metadata = "1.2";
#       devices = [
#         "/dev/disk/by-id/ata-WDC_WD10JUCT-63CYNY0_WD-WXL1A56D5ND9-part1"
#         "/dev/disk/by-id/ata-WDC_WD10JUCT-63CYNY0_WD-WX81EC59L6DM-part1"
#       ];
#       name = "data";
#     };
#   };

  fileSystems = {
  #   "/mnt/raid" = {
  #     device = lib.mkForce "/dev/md127";
  #     fsType = "ext4";
  #     # options = [ "noatime" "rw" "uid=ca" "gid=users" "mode=0775" ];
  #   };

    "/" = {
      device = lib.mkForce "/dev/disk/by-uuid/90f78c45-4232-49be-b19a-3b6960d4b88b";
      fsType = "ext4";
    };

    "/boot" = {
      device = lib.mkForce "/dev/disk/by-uuid/4CF1-664A";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # swapDevices = [{
  #   device = "/mnt/raid/swapfile";
  #   size = 36 * 1024; # 36 GB in MB
  # }];

  # Variables
  environment = {
    variables = { # Also see DPI-Hi.nix
      _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"; # Unknown effects
      QT_AUTO_SCREEN_SCALE_FACTOR = "1"; # Unknown effects
    };
    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      NIXOS_OZONE_WL = "1";
    };
  };

  services = {
    fstrim.enable = true;
    # mdadm.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
}
