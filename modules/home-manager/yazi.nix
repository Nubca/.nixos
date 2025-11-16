{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz.override { useUasm = true; };
    };
    enableFishIntegration = true;
    settings = {
      mgr = {
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<C-n>";
          run = '' shell --confirm 'ripdrag "$@" -x 2>/dev/null &' '';
        }
      ];
    };
  };
}
