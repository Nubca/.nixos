{ config, pkgs, lib, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      autofit-larger = "100%x100%";
      osd-playing-msg = "File: ${filename}";
      hwdec = yes;
      # The 4 options below from Pseudo Gui Profile
      terminal = no;
      force-window = yes;
      idle = once;
      screenshot-directory = ~/Pictures/mpv;
    };
  };
}
