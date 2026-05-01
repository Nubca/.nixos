{ config, inputs, lib, pkgs, ... }:

{
  programs = {
    dconf.enable = true;
    niri.enable = true;

    dms-shell = {
      enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
      systemd = {
        enable = true;             # Systemd service for auto-start
        restartIfChanged = true;   # Auto-restart dms.service when dankMaterialShell changes
      };
      # Core features
      enableSystemMonitoring = true;     # System monitoring widgets (dgop)
      enableClipboardPaste = true;       # Clipboard pasting
      enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;      # Audio visualizer (cava)
      enableCalendarEvents = true;       # Calendar integration (khal)
    };
  };

  services = {
    displayManager = {
      defaultSession = "niri";
      sessionPackages = [
        (pkgs.niri.override {
          # This ensures Niri always starts with a D-Bus session
          # which is required for the Keyring to 'hand off' the password.
          withDbus = true;
        })
      ];
    };
  };

  environment.sessionVariables = {
    PASSWORD_STORE = "gnome-keyring";
    QT_LOGGING_RULES = ''
    qml.AudioService.warning=false;
    qml.i3sock.warning=false;
    qml.swaysock.warning=false;
    '';
    XCURSOR_SIZE = "28";
    XCURSOR_THEME = "Adwaita";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    NIXOS_OZONE_WL = "1";
    GNOME_KEYRING_CONTROL = "/run/user/1001/keyring";
    GNOME_KEYRING_PID = "1"; # A placeholder to trigger the check
    SSH_AUTH_SOCK = "/run/user/1001/keyring/ssh";
    # Prevents Zoom Crashes
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = lib.mkDefault [ "gnome" "gtk" "wlr" ];
    config.niri.default = lib.mkDefault [ "gnome" "gtk" "wlr" ];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    niri
    pass-wayland
    wayland
    wl-clipboard
    xwayland-satellite
  ];
}
