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
        ];
      "wa".imports = [
        ../../users/wahome.nix
      ];
    };
  };
  
# Define additional user accounts. 
  users.users.wa = {
    isNormalUser = true;
    extraGroups = [ "sudo" "networkmanager" "wheel" "libvirtd" "kvm"];
  };

  environment.systemPackages = with pkgs; [
    obs-studio
    darktable
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.11";
}
