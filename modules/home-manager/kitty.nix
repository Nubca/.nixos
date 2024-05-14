{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    theme = "Adwaita dark";
    font = {
      name = "";
      size = 12;
    };
    settings = {
      confirm_os_window_close = 0;
    };
  };
}
