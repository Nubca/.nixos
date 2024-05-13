{ config, pkgs, lib, ... }:

{
  imports = [ ./bash.nix ./helix.nix ];
  options.base.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
}
