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
    # resumeDevice = lib.mkForce "/dev/disk/by-uuid/28328f99:0625df97:72836534:1327af59";
  };

  # swapDevices = [{
  #   device = "/mnt/raid/swapfile";
  #   size = 36 * 1024; # 36 GB in MB
  # }];

  fileSystems = {
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
