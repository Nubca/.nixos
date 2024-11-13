{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ca";
    imports = [ ../modules/home-manager/default.nix ];
    homeDirectory = lib.mkForce "/home/ca";

    sessionVariables = { };

    packages = [ ];

    file = { };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "cabbott008";
      userEmail = "curtisabbott@me.com";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
