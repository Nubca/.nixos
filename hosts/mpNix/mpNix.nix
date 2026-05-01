# ###### Special Config mpNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./mphardware.nix
    ../../modules/nixos/nvidia-mac.nix
    ./mpdisko.nix
    ../../base.nix
    ../../qtile.nix
  ];

  networking.hostName = "mpNix";

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "ca".imports = [ ../../users/cahome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "ca";
      };
    };
    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
      percentageCritical = 5;
    };
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = 0;
        USB_WHITELIST = "3297:1969"; # Prevent MoonLander sleep
      };
    };
  };

  environment.systemPackages = with pkgs; [
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
