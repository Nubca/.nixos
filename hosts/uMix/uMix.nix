####### Special Config uMix.nix #######

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./uhardware.nix
    ./udisko.nix
    ../../base.nix
    ../../qtile.nix
  ];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-59-6.17.7"
    ];
  };

  services = {
    logind = {
      powerKey = lib.mkForce "suspend";
    };
    displayManager = {
      autoLogin = {
        enable = true;
        user = "wa";
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "uMix";
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "admin".imports = [ ../../users/amhome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };

  environment.systemPackages = with pkgs; [
  ];

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.11";
}
