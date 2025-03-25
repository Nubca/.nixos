# ###### Special Config tNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./thardware.nix
    ./tdisko.nix
    ../../base.nix
  ];

  environment.sessionVariables = { FLAKE = "/home/ca/.nixos"; };
  networking.hostName = "tNix";

  networking = {
    networkmanager = {
      wifi.backend = lib.mkForce "wpa_supplicant";
    };
    wireless = {
      iwd = { # Trouble auto-connecting on tNix
        enable = lib.mkForce false;
      };
    };
  };
  
  services.displayManager = {
    enable = true; 
    defaultSession = "qtile";
    autoLogin = {
      enable = true;
      user = "ct";
    };
  };  

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "admin".imports = [ ../../users/amhome.nix ];
      "ca".imports = [ ../../users/cahome.nix ];
      "ct".imports = [ ../../users/cthome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };


  # Define additional user accounts. 
  users.users = {
    ca = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm"];
      linger = true;
    };

    ct = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ]; 
    };
  
    wa = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "libvirtd" "kvm"];
    };

    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" ]; # mpNix public key
    };
  };

  security.sudo.wheelNeedsPassword = false;
  services = {
    openssh.enable = true;
    fail2ban.enable = true;
  };

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
