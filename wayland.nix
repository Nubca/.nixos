{ config, inputs, lib, pkgs, ... }:

let
  xdpwChooser = pkgs.writeShellScript "xdpw-chooser" ''
    log=/tmp/xdpw-chooser.log
    input="$(cat)"

    {
      printf '%s\n' "--- $(${pkgs.coreutils}/bin/date --iso-8601=seconds) ---"
      printf 'input:\n%s\n' "$input"
    } >> "$log"

    choice="$(printf '%s\n' "$input" | ${pkgs.wofi}/bin/wofi --dmenu --prompt Screenshare)" || exit 0

    printf 'choice: %s\n' "$choice" >> "$log"
    printf '%s\n' "$choice"
  '';
in
{
  nixpkgs.overlays = [
    (final: prev: {
      vesktop = prev.vesktop.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          substituteInPlace $out/bin/vesktop \
            --replace '--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true' \
                      '--ozone-platform=wayland --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true'
        '';
      });
    })
  ];

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
      XCURSOR_SIZE = "36";
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
        default = lib.mkDefault [ "gtk" "wlr" ];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
      sway = {
        default = lib.mkDefault [ "gtk" ];
        "org.freedesktop.impl.portal.Inhibit" = "none";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    wlr = {
      enable = true;
      settings = {
        screencast = {
          chooser_type = "dmenu";
          chooser_cmd = "${xdpwChooser}";
          max_fps = 60;
          force_mod_linear = true;
        };
      };
    };
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
