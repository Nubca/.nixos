# ###### Special Config mpNix.nix #######

{ config, inputs, lib, modulesPath, home-manager, ... }:

{
  imports = [
    ./mphardware.nix
    inputs.disko.nixosModules.default
    (import ./mpdisko.nix { device = "/dev/sda"; })
    ../../base.nix
  ];

  networking.hostName = "mpNix";

  services.displayManager.autoLogin = {
    enable = true;
    user = "ca";
  };
  
  home-manager = {
    users = { "ca" = import ../../users/cahome.nix; };
  };
}
