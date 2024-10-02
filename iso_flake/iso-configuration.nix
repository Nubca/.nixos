{ config, pkgs, lib, ... }:

{
  # Use the latest Linux kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages;

  # Include necessary drivers for older Macs
  boot.initrd.availableKernelModules = [ "xhci_pci" "ata_piix" "ohci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];

  # boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # Enable support for Mac-specific hardware
  hardware.enableAllFirmware = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Extra Features  
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Network Settings
  networking = {
    hostName = "iso";
    wireless = {
      enable = true;
    };  
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config = {
      allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    git
    gparted
    neovim
    pciutils
    usbutils
    yazi
    wget
  ];

  # Extra Flexibility
  users.extraUsers.root.password = lib.mkForce "nixos";
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.enable = true;
  networking.useDHCP = lib.mkDefault true;
}
