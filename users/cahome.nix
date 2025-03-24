{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ca";
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
      userName = "Curtis Abbott";
      userEmail = "inspiredplans@gmail.com";
      extraConfig = {
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
