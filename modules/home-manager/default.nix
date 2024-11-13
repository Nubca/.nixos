{ config, pkgs, lib, dconf,... }:

{
  imports = [
    ./bash.nix
    ./fish.nix
    ./kitty.nix
    ./lazygit.nix
    ./mpv.nix
    ./copyq.nix
    ./sxhkd.nix
    ./yazi.nix
    ./zellij.nix
  ];

  options.base.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
  config.dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
