# ###### Special Config mpNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./mphardware.nix
    ../../modules/nixos/nvidia-mac.nix
    inputs.disko.nixosModules.default
    (import ./mpdisko.nix { device = "/dev/sda"; })
    ../../base.nix
  ];

  networking.hostName = "mpNix";

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "ca" = import ../../users/cahome.nix; };
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "ca";
  };

 # Necessary for QMK
  hardware.keyboard.qmk.enable = true;
 # Necessary for QMK
  environment.systemPackages = [
    pkgs.qmk-udev-rules
  ];
}
