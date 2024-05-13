{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ct";
    homeDirectory = lib.mkForce "/home/ct";

    sessionVariables = { };

    packages = [ ];

    file = { };
  };
