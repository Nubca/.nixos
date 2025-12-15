{ config, pkgs, lib, dconf,... }:

{
  imports = [
    ./bash.nix
    ./fish.nix
    ./ghostty.nix
    ./kde-connect.nix
    ./kitty.nix
    ./lazygit.nix
    ./mpv.nix
    ./copyq.nix
    ./sxhkd.nix
    ./vivaldi-theme.nix
    ./yazi.nix
    ./zellij.nix
    ./zoom-us.nix
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
