{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
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
    swraid = {
      enable = true;
      mdadmConf = ''
        MAILADDR root@localhost
      '';
    };
# Set the resume device to the UUID of the swap partition
    resumeDevice = lib.mkForce "/dev/disk/by-uuid/2d2042ab-b7f9-4289-9c73-8c03c366a708";
  # Set kernel parameters for hibernation
    kernelParams = [
      "resume_offset=34816"
      "nvidia-drm.modeset=1"
    ];
    kernelModules = [
      "kvm-intel"
    ];
    extraModulePackages = [
    ];
    kernel.sysctl = { # Limit RAID resync speed so it doesn’t kill the system
      "dev.raid.speed_limit_min" = 1000;
      "dev.raid.speed_limit_max" = 100000;
    };
  };

  swapDevices = [{
    device = "/data/swapfile";
    size = 36 * 1024; # 36 GB in MB
  }];

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

  services.fstrim.enable = true;

  fileSystems = {
    "/data" = {
      device = lib.mkForce "/dev/disk/by-uuid/2d2042ab-b7f9-4289-9c73-8c03c366a708";
      fsType = "ext4";
      options = [ "defaults" "noatime" ];
    };

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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
}
