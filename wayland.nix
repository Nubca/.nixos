{ config, inputs, lib, pkgs, ... }:

{
  programs = {
    dconf.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };

  services = {
    xserver.enable = true;
    displayManager.gdm = {
      enable = true;
    };
  };

  security.pam.services.gdm.enableGnomeKeyring = true;

  environment = {
    sessionVariables = {
      PASSWORD_STORE = "gnome-keyring";
      QT_LOGGING_RULES = ''
      qml.AudioService.warning=false;
      qml.i3sock.warning=false;
      qml.swaysock.warning=false;
      '';
      XCURSOR_SIZE = "28";
      XCURSOR_THEME = "Adwaita";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      GNOME_KEYRING_CONTROL = "/run/user/1001/keyring";
      GNOME_KEYRING_PID = "1"; # A placeholder to trigger the check
      SSH_AUTH_SOCK = "/run/user/1001/keyring/ssh";
      # Prevents Zoom Crashes
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = lib.mkDefault [ "gnome" "gtk" "wlr" ];
        "org.freedesktop.impl.portal.FileChooser" = "gnome";
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    swaybg
    swayidle
    swaylock
    pass-wayland
    wofi
    cliphist
    grim
    slurp
    mako
    wayland
    wl-clipboard
    xwayland-satellite
    gtk3
    nautilus
  ];
}
