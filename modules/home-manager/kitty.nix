{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    theme = "Adwaita dark";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      confirm_os_window_close = 0;
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
    };
  };
}
