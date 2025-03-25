####### Special Config uMix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./uhardware.nix
    ./udisko.nix  
    ../../base.nix
  ];
  
  environment.sessionVariables = { FLAKE = "/home/admin/.nixos"; };
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
    backupFileExtension = "backup";
    users = {
      "admin".imports = [ ../../users/amhome.nix ];
      "ca".imports = [ ../../users/cahome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };
  
# Define additional user accounts. 
  users.users = {
    ca = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm"];
    };
  
    wa = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm"];
    };

    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm"];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" ]; # mpNix public key
    };
  };

  security.sudo.wheelNeedsPassword = false;
  services = {
    openssh.enable = true;
    fail2ban.enable = true;
  };
 
  environment.systemPackages = with pkgs; [
    obs-studio
    darktable
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.11";
}
