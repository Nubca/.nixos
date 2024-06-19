# ###### Special Config tNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./thardware.nix
    inputs.disko.nixosModules.default
    (import ./tdisko.nix { device = "/dev/sda"; })
    ../../base.nix
  ];

  networking.hostName = "tNix";

  networking = {
    networkmanager = {
      wifi.backend = lib.mkForce "wpa_supplicant";
    };
    wireless = {
      iwd = { # Trouble auto-connecting on tNix
        enable = lib.mkForce false;
      };
    };
  };
  
  services.displayManager = {
    enable = true; 
    defaultSession = "qtile";
    autoLogin = {
      enable = true;
      user = "ct";
    };
  };  

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "ca" = import ../../users/cahome.nix;
      "ct" = import ../../users/cthome.nix;
      "wa" = import ../../users/wahome.nix;
    };
  };

  # Define additional user accounts. 
  users.users.ct = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

  users.users.wa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };
}
