{ config, pkgs, lib, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Fuchsia-Red";
    name = "Fuchsia-Red";
    size = 48;
    package = pkgs.fuchsia-cursor;
  };
}
