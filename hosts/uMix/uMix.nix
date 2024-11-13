####### Special Config uMix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./uhardware.nix
    ./udisko.nix  
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
      "ca".imports = [
          ../../users/cahome.nix
          ../../modules/home-manager/default.nix
        ];
      "wa".imports = [
        ../../users/wahome.nix
        ../../modules/home-manager/default.nix
      ];
    };
  };
  
# Define additional user accounts. 
  users.users.wa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ]; 
  };

  environment.systemPackages = with pkgs; [
    obs-studio
    darktable
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.11";
}
