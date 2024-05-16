{ config, pkgs, lib, ... }:

{
  services.copyq = {
    enable = true;
    systemdTarget = "graphical-session.target";
  };
}
