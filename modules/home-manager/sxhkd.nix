{ config, pkgs, lib, ... }:

{
  services.sxhkd = {
    enable = true;
    keybindings = {
      # Don't use Control + Tab it messes up defaults
      "control + alt + f" = "flameshot gui &";
      "control + p" = "kitty -e btop";
      "control + shift + Return" = "pcmanfm";
      "control + q" = "kitty";
      "super + b" = "vivaldi";
      "super + shift + e" = "rofimoji";
      "super + p" = "rofi -show drun";
      "super + w" = "rofi -show window";
      "super + v" = "pavucontrol";
      "super + shift + s" = "pkill -USR1 -x sxhkd";
      "super + shift + o" = "obsidian";
      "super + h" = "copyq toggle";
    };
  };
}
