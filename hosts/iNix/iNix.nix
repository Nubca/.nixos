####### Special Config iNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
      ./ihardware.nix
      inputs.disko.nixosModules.default
        (import ./idisko.nix { device = "/dev/sda"; })  
      ../../base.nix
    ];

    networking.hostName = "iNix";

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users = { "ca" = import ../../home.nix; };
      users = { "ct" = import ../../home.nix; };
      users = { "wa" = import ../../home.nix; };
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
