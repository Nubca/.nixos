{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ct";
    imports = [ ../modules/home-manager/default.nix ];
    homeDirectory = lib.mkForce "/home/ct";

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
      userName = "thaxer";
      userEmail = "thaxtonconnie@yahoo.com";
    };
  };
}
