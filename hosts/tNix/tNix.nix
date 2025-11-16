# ###### Special Config tNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
    imports = [
    ./thardware.nix
    ./tdisko.nix
    ../../base.nix
  ];

  environment.sessionVariables = { NH_FLAKE = "/home/admin/.nixos"; };

  networking = {
    hostName = "tNix";
    networkmanager = {
      wifi.backend = lib.mkForce "wpa_supplicant";
    };
    wireless = {
      iwd = { # Trouble auto-connecting on tNix
        enable = lib.mkForce false;
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    displayManager = {
      enable = true;
      defaultSession = "qtile";
      autoLogin = {
        enable = true;
        user = "ct";
      };
    };
    openssh.settings = {
      AllowUsers = [ "admin" ];
      PasswordAuthentication = true; # Disable password authentication for security
      PermitRootLogin = "no";         # Prohibit root login
      UseDns = false;                 # Speed up SSH connections
      ClientAliveInterval = 300;      # Keep the connection alive
      ClientAliveCountMax = 1;        # Terminate unresponsive sessions
    };
    fail2ban.enable = true;
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

    wa = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "libvirtd" "kvm"];
    };

    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" # mpNix public key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEcufvqpzURfwPzHI8uaEzLCLkNuOe/zezQfJ8uB40UE" # iNix public key"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINRvb/eEDa62lqhMxGE4CEiyF+qLTtx/E/IXtfIwtTP inspiredplans@gmail.com" # pNix public key
      ];
    };
  };

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
