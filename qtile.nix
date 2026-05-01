{ inputs, pkgs, lib, ... }: {

  imports = [
    ./qtile/qtile.nix
  ];

  services = {
    xserver = {
      enable = true;
      excludePackages = with pkgs; [ xterm ];

      displayManager = {
        lightdm = {
          enable = true;
          greeters.gtk.enable = true;
        };
      };

      windowManager.qtile = {
        enable = true;
      };
    };

    displayManager = {
      defaultSession = "qtile";
    };
  };

  environment.sessionVariables = {
    PASSWORD_STORE = "gnome-keyring";
    XCURSOR_SIZE = "28";
    XCURSOR_THEME = "Adwaita";
    XDG_SESSION_TYPE = "x11";
    XDG_CURRENT_DESKTOP = "qtile";
    XDG_SESSION_DESKTOP = "qtile";
    GNOME_KEYRING_CONTROL = "/run/user/1001/keyring";
    GNOME_KEYRING_PID = "1"; # A placeholder to trigger the check
    SSH_AUTH_SOCK = "/run/user/1001/keyring/ssh";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = [ "gtk" ];
  };

  environment.systemPackages = with pkgs; [
    sxhkd
    xcb-util-cursor # Needed for Qtile Cursor change
    xclip
    xdotool
    xsel
  ];
}
