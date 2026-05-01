# ###### Special Config tNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
    imports = [
    ./thardware.nix
    ./tdisko.nix
    ../../base.nix
    ../../qtile.nix
  ];

  networking = {
    hostName = "tNix";
    networkmanager = {
      wifi.backend = lib.mkForce "wpa_supplicant";
    };
    wireless = {
      iwd = { # Trouble auto-connecting on tNix
        enable = lib.mkForce false;
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "ct";
      };
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "admin".imports = [ ../../users/amhome.nix ];
      "ct".imports = [ ../../users/cthome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };


  # Define additional user accounts.
  users.users = {
    ct = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
  };

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
