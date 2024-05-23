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
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
    ];
  };
  
  # services.xserver = {
  #   dpi = 288; # Seems to have no effect without the below
  #   upscaleDefaultCursor = true; # Causes ptr_left to override custom cursor
  # };
  
  # Variables
  environment = {
    variables = { # Also see DPI-Hi.nix
      # GDK_SCALE = "2"; # Not Needed with DPI-Hi.nix
      # GDK_DPI_SCALE = "0.5"; # Not Needed with DPI-Hi.nix
      _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"; # Unknown effects
      QT_AUTO_SCREEN_SCALE_FACTOR = "1"; # Unknown effects
    };
  };

  services.mbpfan.enable = true;
  services.fstrim.enable = true;
}
