{ config, pkgs, lib, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Adwaita";
    name = "Adwaita";
    # size = 48;
    package = pkgs.gnome.adwaita-icon-theme;
  };
}
