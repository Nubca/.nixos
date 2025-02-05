{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
      };
# Set the resume device to the UUID of the swap partition
    resumeDevice = lib.mkForce "/dev/disk/by-uuid/dd99c3a8-92a3-446c-b350-09c4ad7f0913";
  # Set kernel parameters for hibernation
    kernelParams = [
      "resume=UUID=dd99c3a8-92a3-446c-b350-09c4ad7f0913"  # Resume from the swap partition
    ];
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
    ];
  };
  
  # Specify the swap device
  swapDevices = [
    { device = "/dev/disk/by-uuid/dd99c3a8-92a3-446c-b350-09c4ad7f0913"; }
  ]; 

  # Variables
  environment = {
    variables = { # Also see DPI-Hi.nix
      _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"; # Unknown effects
      QT_AUTO_SCREEN_SCALE_FACTOR = "1"; # Unknown effects
    };
  };

  services.mbpfan.enable = true;
  services.fstrim.enable = true;
}
