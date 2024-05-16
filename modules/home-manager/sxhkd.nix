{ config, pkgs, lib, ... }:

{
  services.sxhkd = {
    enable = true;
    keybindings = {
      "control + alt + f" = "flameshot gui &";
      "super + b" = "vivaldi";
      "control + p" = "kitty -e btop";
      "atl + shift + e" = "rofimoji";
      "super + p" = "rofi -show drun";
      "super + w" = "rofi -show window";
      "super + v" = "pavucontrol";
      "super + Return" = "kitty";
      "super + Escape" = "xkill";
      "super + shift + Return" = "pcman";
      "super + shift + s" = "pkill -USR1 -x sxhkd";
      "super + shift + o" = "obsidian";
      "super + h" = "copyq toggle";
    };
  };
}
