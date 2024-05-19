{ config, pkgs, lib, ... }:

{
  imports = [
    ./bash.nix
    ./helix.nix
    ./kitty.nix
    ./mpv.nix
    ./copyq.nix
    ./sxhkd.nix
    # ./cursors.nix
    ./xresources.nix
  ];
  
  options.base.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
}
