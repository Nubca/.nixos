{ config, pkgs, lib, ... }:

{
  services.clipmenu = {
    enable = true;
    launcher = "rofi";
  };
}

