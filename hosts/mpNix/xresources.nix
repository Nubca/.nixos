{ config, lib, pkgs, ... }:

{
  xresources.properties = {
    "Xft.dpi" = 192;
    "Xcursor.theme" = "Adwaita";
  };
}
