{ config, pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor = {
        auto-save = true;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        statusline = {
          left = [
            "spinner"
            "file-name"
            "version-control"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          center = [ "mode" ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "file-encoding"
            "total-line-numbers"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
        indent-guides = {
          render = true;
          character = "⸽";
          skip-levels = 1;
        };
        lsp = { display-messages = true; };
        mouse = true;
        cursorline = true;
        bufferline = "always";
        line-number = "relative";
        rulers = [ 120 ];
        true-color = true;
        color-modes = true;
      };
      keys.normal = {
        G = "goto_file_end";
        ret = [ "move_line_down" "goto_line_start" ];
        esc = [ "collapse_selection" "keep_primary_selection" ];
        A-x = "extend_to_line_bounds";
        X = [ "extend_line_up" "extend_to_line_bounds" ];
        space = {
          q = ":quit";
          w = ":write";
        };
      };
      keys.select = {
        A-x = "extend_to_line_bounds";
        X = [ "extend_line_up" "extend_to_line_bounds" ];
      };
    };
    languages.language = [{
      name = "nix";
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };
}
