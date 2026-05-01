# ###### Special Config pNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./phardware.nix
    ../../base.nix
    ../../qtile.nix
  ];

  networking.hostName = "pNix";

  # services = {
  #   xserver.videoDrivers = [ "radeon" ];
  # };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "ca".imports = [ ../../users/cahome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };

  # services = {
  #   displayManager = {
  #     autoLogin = {
  #       enable = true;
  #       user = "ca";
  #     };
  #   };
  # };

 # Necessary for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}"];
 # Necessary for QMK
  hardware.keyboard.qmk.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
      MODE="0666", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", \
      MODE="0666", GROUP="plugdev", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    brave
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
