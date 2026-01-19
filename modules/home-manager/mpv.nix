{ config, pkgs, lib, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      # autofit-larger = "100%x100%";
      # osd-playing-msg = "File: ${filename}";
      hwdec = true;
      # The 4 options below from Pseudo Gui Profile
      terminal = false;
      # force-window = true;
      idle = "once";
      screenshot-directory = "../../../Pictures";
      extraInput = ''
        B script_message bookmarker-menu
        b script_message bookmarker-quick-save
        ctrl+b script_message bookmarker-quick-load
      '';
    # scripts = [
    #   mpv-webm
    #   ];
    };
  };
}
