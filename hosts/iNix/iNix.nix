####### Special Config iNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./ihardware.nix
    ../../modules/nixos/nvidia-mac.nix
    inputs.disko.nixosModules.default
      (import ./idisko.nix { device = "/dev/sda"; })  
    ../../base.nix
  ];
  
  networking.hostName = "iNix";

  services.displayManager = {
    enable = true; 
    defaultSession = "none+qtile";
    autoLogin = {
      enable = false;
      user = "wa";
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
