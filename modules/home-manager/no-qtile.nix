# modules/qtile.nix
{ config, ... }:

{
  qtile.extraConfig = ''
    from libqtile.config import Key
    keys.extend([
        Key(["mod4", "control"], "q", lazy.spawn("rofi-logout"))
    ])
  '';
}
