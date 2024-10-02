####### Special Config uMix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./uhardware.nix
    ../../modules/nixos/nvidia-mac.nix
    inputs.disko.nixosModules.default
      (import ./udisko.nix { device = "/dev/sda"; })  
    ../../base.nix
  ];
  
  networking.hostName = "uMix";

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
      "wa" = import ../../users/wahome.nix;
    };
  };
  
# Define additional user accounts. 
  users.users.wa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ]; 
  };

  environment.systemPackages = with pkgs; [
    obs-studio
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.11";
}
