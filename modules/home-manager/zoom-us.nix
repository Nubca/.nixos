{ config, pkgs, lib, ... }:

{
  home.file.".config/zoomus.conf".source = pkgs.writeText "zoomconfig" ''
    [General]
    xwayland=false
    enableWaylandShare=true
  '';
}
