####### Special Config iNix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./ihardware.nix
    ../../modules/nixos/nvidia-mac.nix
      ./idisko.nix
    ../../base.nix
  ];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-59-6.12.57"
    ];
  };

  environment.sessionVariables = { NH_FLAKE = "/home/admin/.nixos"; };
  networking.hostName = "iNix";

  security.sudo.wheelNeedsPassword = false;

  services = {
    logind.seetings.Login = {
      HandlePowerKey = lib.mkForce "suspend";
    };
    displayManager = {
      enable = true;
      defaultSession = "qtile";
      autoLogin = {
        enable = true;
        user = "wa";
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
    wa = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm"];
    };
    ct = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" # mpNix public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINRvb/eEDa62lqhMxGE4CEiyF+qLTtx/E/IXtfIwtTP inspiredplans@gmail.com" # pNix public key
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    obs-studio
    darktable
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
