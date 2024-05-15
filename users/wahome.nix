{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "wa";
    homeDirectory = lib.mkForce "/home/wa";

    sessionVariables = { };

    packages = [ ];

    file = {
      *.force = true;
    }; 
  };
  
  programs = {
    home-manager = {
      enable = true;
    };
  };
}
