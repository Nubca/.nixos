{ config, lib, pkgs, ... }:

{
  xresources.properties = {
    "Xcursor.theme" = "Adwaita";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Adwaita";
    name = "Adwaita";
    size = 32;
    package = pkgs.gnome.adwaita-icon-theme;
  };
}
