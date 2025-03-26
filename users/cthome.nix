{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ct";
    homeDirectory = lib.mkForce "/home/ct";

    sessionVariables = { };

    packages = [ ];
  
    file = {
      ".config/qtile/0-Monitor.jpg".source = ../qtile/0-Monitor.jpg;
      ".config/qtile/1-Main.jpg".source = ../qtile/0-Monitor.jpg;
      ".config/qtile/autostart.sh".source = ../qtile/autostart.sh;
    };
  };
  
  programs = {
    home-manager = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "Connie Thaxton";
      userEmail = "thaxtonconnie@yahoo.com";
    };
  };
}
