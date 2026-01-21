# ###### Special Config nNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./nhardware.nix
    ../../base.nix
  ];

  # nixpkgs.overlays = [
  #     (self: super: {
  #       zoom-us = super.zoom-us.overrideAttrs (oldAttrs: {
  #         postFixup = (oldAttrs.postFixup or "") + ''
  #           wrapProgram $out/bin/zoom-us \
  #             --set XCURSOR_SIZE 28 \
  #             --set QT_AUTO_SCREEN_SCALE_FACTOR 1 \
  #             --set QT_WAYLAND_DISABLE_WINDOWDECORATION 1 \
  #             --set QT_QPA_PLATFORM "wayland" \
  #             --run 'export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring'
  #             --add-flags "--no-keyring"
  #         '';
  #       });
  #     })
  #   ];

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

  environment.sessionVariables = {
    NH_FLAKE = "/home/ca/.nixos";
    PASSWORD_STORE = "gnome-keyring";
    QT_LOGGING_RULES = ''
    qml.AudioService.warning=false;
    qml.i3sock.warning=false;
    qml.swaysock.warning=false;
    '';
    XCURSOR_SIZE = "28";
    XCURSOR_THEME = "Adwaita";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "gnome";
    XDG_SESSION_DESKTOP = "niri";
    NIXOS_OZONE_WL = "1";
    GNOME_KEYRING_CONTROL = "/run/user/1001/keyring";
    GNOME_KEYRING_PID = "1"; # A placeholder to trigger the check
    SSH_AUTH_SOCK = "/run/user/1001/keyring/ssh";
    # Prevents Zoom Crashes
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  powerManagement.cpuFreqGovernor = "performance";
  virtualisation = {
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Allows 'docker' commands
    };
  };

  xdg = {
    portal = {
      config.common.default = lib.mkDefault [ "gnome" "gtk" "wlr" ];
      config.niri.default = lib.mkDefault [ "gnome" "gtk" "wlr" ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      wlr.enable = true;
    };
  };

  security = {
    polkit.enable = true;
    pam.services = {
      gdm.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };

  services = {
    flatpak = {
      enable = true;
      update.auto.enable = true;
      packages = [
        "us.zoom.Zoom"
      ];
    };
    dbus.packages = [ pkgs.gcr ];
    dbus.implementation = "broker"; # Modern, faster DBus
    xserver.videoDrivers = [ "nvidia" ];
    displayManager = {
      enable = true;
      gdm.enable = true;
      defaultSession = "niri";
      autoLogin = {
        enable = false;
        user = "ca";
      };
      sessionPackages = [
        (pkgs.niri.override {
          # This ensures Niri always starts with a D-Bus session
          # which is required for the Keyring to 'hand off' the password.
          withDbus = true;
        })
      ];
    };
    gnome.gnome-keyring.enable = true;
    pipewire = {
      # jack.enable = true;
      wireplumber.enable = true;
      pulse.enable = true;
    };
    openssh.settings = {
      AllowUsers = [ "admin" ];
      PasswordAuthentication = true; # Disable password authentication for security
      PermitRootLogin = "no";         # Prohibit root login
      UseDns = false;                 # Speed up SSH connections
      ClientAliveInterval = 300;      # Keep the connection alive
      ClientAliveCountMax = 1;        # Terminate unresponsive sessions
    };
    fail2ban.enable = true;
    logind = {
      # powerKey = "hibernate";
      # powerKeyLongPress = "poweroff";
    };
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP-LaserJet";
        location = "Home";
        deviceUri = "usb://HP/LaserJet%20Professional%20P1102w?serial=000000000Q9238NAPR1a";
        model = "HP/hp-laserjet_professional_p_1102w.ppd.gz";
      }
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "ca".imports = [ ../../users/cahome.nix ];
      "wa".imports = [ ../../users/wahome.nix ];
    };
  };

# Define a user account.
  users.users = {
    ca = {
      isNormalUser = true;
      extraGroups = [ "sudo" "networkmanager" "wheel" "libvirtd" "kvm"];
      linger = true;
      openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" # mpNix public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEcufvqpzURfwPzHI8uaEzLCLkNuOe/zezQfJ8uB40UE" # iNix public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINRvb/eEDa62lqhMxGE4CEiyF+qLTtx/E/IXtfIwtTP inspiredplans@gmail.com" # pNix public key
      ];
    };

    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" # mpNix public key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEcufvqpzURfwPzHI8uaEzLCLkNuOe/zezQfJ8uB40UE" # iNix public key"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINRvb/eEDa62lqhMxGE4CEiyF+qLTtx/E/IXtfIwtTP inspiredplans@gmail.com" # pNix public key
      ];
    };

    wa = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
  };

  networking = {
    hostName = "nNix";
    firewall = {
      # allowedTCPPorts = [ 22 ];
      allowedTCPPortRanges = [
        { from = 53317; to = 53317; } # LocalSend
        { from = 1714; to = 1764; } # kdeconnect
      ];
      allowedUDPPortRanges = [
        { from = 53315; to = 53318; } # LocalSend
        { from = 4000; to = 4007; } # LocalSend
        { from = 8000; to = 8010; } # LocalSend
        { from = 1714; to = 1764; } # kdeconnect
      ];
      extraCommands = ''
        iptables -A INPUT -p tcp --dport 53317 -s 192.168.0.0/24 -j ACCEPT
        iptables -A INPUT -p udp --dport 53315:53318 -s 192.168.0.0/24 -j ACCEPT
        iptables -A INPUT -p udp --dport 4000:4007 -s 192.168.0.0/24 -j ACCEPT
        iptables -A INPUT -p udp --dport 8000:8010 -s 192.168.0.0/24 -j ACCEPT
        iptables -A INPUT -p tcp --dport 1714:1764 -s 192.168.0.0/24 -j ACCEPT
        iptables -A INPUT -p udp --dport 1714:1764 -s 192.168.0.0/24 -j ACCEPT
        iptables -A INPUT -p tcp --dport 53317 ! -s 192.168.0.0/24 -j DROP
        iptables -A INPUT -p udp --dport 53315:53318 ! -s 192.168.0.0/24 -j DROP
        iptables -A INPUT -p udp --dport 4000:4007 ! -s 192.168.0.0/24 -j DROP
        iptables -A INPUT -p udp --dport 8000:8010 ! -s 192.168.0.0/24 -j DROP
        iptables -A INPUT -p tcp --dport 1714:1764 ! -s 192.168.0.0/24 -j DROP
        iptables -A INPUT -p udp --dport 1714:1764 ! -s 192.168.0.0/24 -j DROP
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    browserpass
    clickup
    # cliphist
    # darktable
    distrobox
    dosfstools
    # davinci-resolve
    gimp
    gparted
    hfsprogs
    hplipWithPlugin
    # inkscape
    mtools
    mdadm
    niri
    nixd
    nodejs
    npins
    obs-studio
    pass-wayland
    pwvucontrol
    python3
    telegram-desktop
    tradingview
    seahorse
    swww
    # qmk
    # qmk-udev-rules
    # reaper
    thunderbird
    wayland
    wl-clipboard
    xwayland-satellite
  ];

 # Necessary for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}"];
 # Necessary for QMK
  hardware.keyboard.qmk.enable = true;

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
