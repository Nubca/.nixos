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

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "ct" = import ./thome.nix; };
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
