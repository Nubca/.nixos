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
      #     backupFileExtension = "backup";
    };
    bash = {
      enable = true;
      bashrcExtra = ''
        if [[ $- == *i* && $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" ]]
        then
          exec ${pkgs.fish}/bin/fish
        fi
      '';
    };

    git = {
      enable = true;
      userName = "cabbott008";
      userEmail = "curtisabbott@me.com";
    };

    helix = {
      enable = true;
      settings = {
        theme = "autumn_night_transparent";
        editor = {
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp = { display-messages = true; };
          line-number = "relative";
          true-color = true;
        };
        keys.normal = {
          G = "goto_file_end";
          ret = [ "move_line_down" "goto_line_start" ];
          space = {
            q = ":quit";
            w = ":write";
          };
        };
      };
      languages.language = [{
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }];
      themes = {
        autumn_night_transparent = {
          "inherits" = "autumn_night";
          "ui.background" = { };
        };
      };
    };
  };
}
