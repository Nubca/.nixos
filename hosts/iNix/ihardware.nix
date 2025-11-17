{ config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "hid_apple"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];
    };
    kernelModules = [
      "kvm-intel"
      "b43" # This is the open source option and it works so-so
      # "wl" # The package below for Broadcom is insecure
    ];
    blacklistedKernelModules = [
      # "b43"
      "wl"
      "ssb"
      "brcmfmac"
      "brcmsmac"
      "bmca"
    ];
    extraModulePackages = [
      # config.boot.kernelPackages.broadcom_sta
    ];
  };
  hardware.enableAllFirmware = true;
}
