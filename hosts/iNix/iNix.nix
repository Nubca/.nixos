####### Special Config iNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./ihardware.nix
    ../../modules/nixos/nvidia-mac.nix
      ./idisko.nix  
    ../../base.nix
  ];
  
  networking.hostName = "iNix";

  services = {
    logind = {
      powerKey = lib.mkForce "suspend";
    };
    displayManager = {
      enable = true; 
      defaultSession = "qtile";
      autoLogin = {
        enable = true;
        user = "wa";
      };
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

  environment.systemPackages = with pkgs; [
    obs-studio
    blender
    darkroom
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
