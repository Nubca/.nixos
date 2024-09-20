{ config, pkgs, lib, dconf,... }:

{
  imports = [
    ./bash.nix
    ./kitty.nix
    ./mpv.nix
    ./copyq.nix
    ./sxhkd.nix
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
