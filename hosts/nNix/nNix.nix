# ###### Special Config nNix.nix #######

{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./nhardware.nix
    ../../base.nix
    ../../wayland.nix
    ../../modules/nixos/kvm-trading.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod_latest;
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    displayManager = {
      autoLogin = {
        enable = true;
        user = "ca";
      };
    };
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
