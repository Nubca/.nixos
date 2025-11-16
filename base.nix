# ----- * NixOS Default Config* - base.nix -----

{ inputs, pkgs, lib, ... }: {
# Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  imports = [
    ./qtile/qtile.nix
  ];

# Variables
  nixpkgs.overlays = [
  ];
# Use the systemd-boot EFI boot loader and specify Linux kernel.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # Switch Kernels via appending _6_12
    # kernelPackages = pkgs.linuxPackages_6_12;
    kernelParams = [
      "mem_sleep_default=s2idle"
      # "usbcore.autosuspend=-1"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      generic-extlinux-compatible.configurationLimit = 10;
    };
    extraModprobeConfig = '' # Prevent WiFi sleep
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
    # options usbcore autosuspend=-1
    '';
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    download-buffer-size = 524288000; # 500MB
    auto-optimise-store = true;
  };

# Network Settings
  hardware.bluetooth.enable = true;

  networking = {
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        backend = "iwd";
      };
      # connectionConfig = {
      #   # Restart interface after 15sec timeout
      #   "connection.auth-retries" = 5;
      #   "connection.dhcp-timeout" = 30;
      #   "connection.autoconnect-retries" = 3;
      #   "connection.autoconnect-timeout" = 60;
      # };
      # Force periodic DHCP renewals
      # dhcp = "dhcpcd";
    };

    wireless = {
      enable = false; # Kills wpa_supplicant
      iwd = { # tNix is on wpa_supplicant
        enable = true;
        settings = {
          Settings = {
            AutoConnect = true;
            RoamRetryInterval = 60;
          };
          General = {
            RoamThreshold = "-70";
            EnableNetworkConfiguration = false; # false passing to NetworkManager fails
          };
          IPv6.Enabled = false;
          Network = {
            RoutePriorityOffset = 300; # Prioritize WiFi routes
          };
        };
      };
    };

    # Selective DHCP for specific interfaces instead of Global
    useDHCP = lib.mkDefault false; # Disables native DHCP

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        # { from = 7496; to = 7497; } # IBKR TWS
      ];
    };
  };

# Enable sound.
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    pulseaudio.enable = false;
  };

# Set your time zone.
  time.timeZone = "America/Chicago";

# Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_INDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

# Power Management
  powerManagement = {
    enable = true;
  };

  systemd = {
    sleep.extraConfig = ''
    HibernateDelaySec=2h
    SuspendState=freeze
    '';
  };

# Enable X11, Desktop Environment, & Misc.
  services = {
    xserver = {
      enable = true;
      autorun = false;
      windowManager.qtile = {
        enable = true;
      };
      xkb = {
        layout = "us";
        variant = "";
        options = "caps:escape";
      };
      displayManager = {
        lightdm = {
          enable = true;
          autoLogin.timeout = 0;
          greeters = {
            gtk.enable = true;
          };
        };
        sessionCommands = ''
          ${pkgs.sxhkd}/bin/sxhkd &
        '';
      };
      excludePackages = with pkgs; [
        xterm
      ];
    };
    libinput = {
      touchpad.naturalScrolling = true;
      mouse.naturalScrolling = true;
    };
    auto-cpufreq.enable = false;
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = 0;
        USB_WHITELIST = "3297:1969"; # Prevent MoonLander sleep
      };
    };
    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
      percentageCritical = 5;
    };
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
    };
    gnome.gnome-keyring.enable = true;
    udisks2.enable = true;
    devmon.enable = true;
    gvfs.enable = true;
    udev.extraRules = ''
      # Prevent Moonland keyboard from sleeping
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", ATTR{power/control}="on"
      # Also disable autosuspend for this device
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", ATTR{power/autosuspend}="-1"
    '';
  };

# Virtualisation
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };
  programs = {
    virt-manager.enable = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 5d";
      };
    };
  };

# Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono
    fg-virgil
    google-fonts
  ];

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
    };
    mime = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      };
      removedAssociations = {
        "application/pdf" = [
          "gimp.desktop"
          "inkscape.Inkscape.desktop"
        ];
      };
    };
  };

# Packages installed system-wide
  environment.systemPackages = with pkgs; [
    audacity
    bat
    bluetuith
    bluez
    bluez-tools
    btop
    devbox
    dunst
    exiftool
    eza
    fastfetch
    fd
    feh
    ffmpeg
    file
    fish
    flameshot
    fzf
    ghostty
    git
    inputs.nvim-flake.packages.${pkgs.stdenv.system}.neovim
    kitty
    lazygit
    localsend
    libqalculate
    mpv
    nix-output-monitor
    nvd
    obsidian
    pavucontrol
    pciutils
    pcmanfm
    pv
    rdfind
    ripdrag
    ripgrep
    rofi
    rofimoji
    ruby
    sd
    tldr
    trash-cli
    tree
    ttyper
    unzip
    usbutils
    vivaldi
    vlc
    vscode
    wget
    xcb-util-cursor # Needed for Qtile Cursor change
    xclip
    xdotool
    xsel
    yt-dlp
    zathura
    zoom-us
    zoxide
  ];
}
