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
    size = 28;
    package = pkgs.gnome.adwaita-icon-theme;
  };

  # home.pointerCursor = 
  #  let 
  #    getFrom = url: hash: name: {
  #        gtk.enable = true;
  #        x11.enable = true;
  #        name = name;
  #        size = 48;
  #        package = 
  #          pkgs.runCommand "moveUp" {} ''
  #            mkdir -p $out/share/icons
  #            ln -s ${pkgs.fetchzip {
  #              url = url;
  #              hash = hash;
  #            }} $out/share/icons/${name}
  #        '';
  #      };
  #  in
  #    getFrom 
  #      "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.0/Fuchsia-Red.tar.gz"
  #      "sha256-i91RzcANAfuaYEywaIzAnrpUl+8VhvLxQrn3NhCVNRA="
  #     # "sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk="
  #      "Fuchsia-Red"; 
}
