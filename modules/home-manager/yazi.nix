{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
        };
      opener = {
        pdf = [
          {
            run = "${pkgs.zathura}/bin/zathura \"$@\"";
            block = true;
          }
        ];
      };
    };
    keymap = {
      manager.prepend_keymap = [
        { 
          on = "<C-n>"; 
          run = 
          '' shell --confirm 'ripdrag "$@" -x 2>/dev/null &' '';
        }
        {
          on = [ "g" "i" ];
          run = "plugin lazygit";
        }
      ];
    };
  };
}
