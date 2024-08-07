{ config, pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
  };
}
