{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        sort_by = "natural";
        sort_dir_first = "true";
      };
      linemode = "size";
      opener = {
        pdf = [
          { run = "'${pkgs.zathura}/bin/zathura \"$@"'"; block = true; }
        ];
      };
    };
  };
}
