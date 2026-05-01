# ###### Special Config nNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./nhardware.nix
    ../../base.nix
    ../../wayland.nix
    ../../modules/nixos/kvm-trading.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest; # Switch Kernels via appending _6_12
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "ca".imports = [ ../../users/cahome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };

  networking.hostName = "nNix";

  environment.systemPackages = with pkgs; [
    brave
  ];

 # Necessary for QMK
  hardware.keyboard.qmk.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
      MODE="0666", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", \
      MODE="0666", GROUP="plugdev", TAG+="uaccess"
  '';

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
