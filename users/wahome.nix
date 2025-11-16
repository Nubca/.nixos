{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "wa";
    homeDirectory = lib.mkForce "/home/wa";

    sessionVariables = { };

    packages = [ ];

    file = {
      ".config/qtile/0-Monitor.jpg".source = ../qtile/WilliamWallpaper.jpg;
      ".config/qtile/1-Main.jpg".source = ../qtile/WilliamWallpaper.jpg;
      ".config/qtile/autostart.sh".source = ../qtile/autostart.sh;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "William Abbott";
          email = "willabbott008@gmail.com";
        };
      };
    };
  };
}
