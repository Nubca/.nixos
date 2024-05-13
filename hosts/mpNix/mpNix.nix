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

        # autoLogin = {
        #   enable = true;
        #   user = "ca";
        # };
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "ca" = import ../../home.nix; };
  };
}
