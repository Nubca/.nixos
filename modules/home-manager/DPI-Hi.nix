{ config, lib, pkgs, ... }:

{
  xresources.properties = { # Also see mphardware.nix
    "Xft.dpi" = 192; #HiDPI compensation
    "Xcursor.theme" = "Adwaita";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Adwaita";
    name = "Adwaita";
    size = 64; # HiDPI compensation
    package = pkgs.adwaita-icon-theme;
  };
}
