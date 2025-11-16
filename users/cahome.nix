{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ca";
    homeDirectory = lib.mkForce "/home/ca";

    sessionVariables = { };

    packages = [ ];

    file = {
      ".config/qtile/0-Monitor.jpg".source = ../qtile/0-Monitor.jpg;
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
      settings = {
        user = {
          name = "Curtis Abbott";
          email = "inspiredplans@gmail.com";
        };
        gpg.format = "openpgp";
        gpg.openpgp.program = "${pkgs.gnupg}/bin/gpg";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
