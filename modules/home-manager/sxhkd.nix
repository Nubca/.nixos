{ config, pkgs, lib, ... }:

{
  services.sxhkd = {
    enable = true;
    keybindings = {
      "control + alt + f" = "flameshot gui &";
      "control + p" = "kitty -e btop";
      "control + Tab" = "kitty";
      "control + Return" = "kitty -e vifm";
      "control + shift + Return" = "pcmanfm";
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
