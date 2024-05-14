{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "root";
    homeDirectory = lib.mkForce "/root";

    sessionVariables = { };

    packages = [ ];

    file = { };
  };

  programs = {
    home-manager = {
      enable = true;
    };
  };
}
