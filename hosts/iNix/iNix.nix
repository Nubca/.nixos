####### Special Config iNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./ihardware.nix
    ../../modules/nixos/nvidia-mac.nix
      ./idisko.nix
    ../../base.nix
    ../../qtile.nix
  ];

  # nixpkgs.config = {
  #   permittedInsecurePackages = [
  #     "broadcom-sta-6.30.223.271-59-6.17.7"
  #   ];
  # };

  networking.hostName = "iNix";

  security.sudo.wheelNeedsPassword = false;

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "wa";
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

  environment.systemPackages = with pkgs; [
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
