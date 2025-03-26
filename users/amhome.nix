{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "admin";
    homeDirectory = lib.mkForce "/home/admin";

    sessionVariables = { };

    packages = [ ];

    file = {
      ".config/qtile/0-Monitor.jpg".source = ../qtile/1-Main.jpg;
      ".config/qtile/1-Main.jpg".source = ../qtile/1-Main.jpg;
      ".config/qtile/autostart.sh".source = ../qtile/autostart.sh;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
  
    git = {
      enable = true;
      userName = "Curtis Abbott";
      userEmail = "inspiredplans@gmail.com";
      extraConfig = {
        gpg.format = "openpgp";
        gpg.openpgp.program = "${pkgs.gnupg}/bin/gpg";
      };
    };
  };
}
