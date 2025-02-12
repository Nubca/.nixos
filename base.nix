# ----- * NixOS Default Config* - base.nix -----

{ inputs, pkgs, lib, ... }: {
  imports = [ ];

# Variables
  environment.sessionVariables = { FLAKE = "/home/ca/.nixos"; };
  nixpkgs = {
    overlays = [
    # (import ./overlays/broadcom-sta-fix.nix)
    # (import ./overlays/nvidia-470-fix.nix)
    ];
    # Added the below and the package myCustomPackages to repair a broadcom-sta-fix related error.
    config.packageOverrides = pkgs: {
      myCustomPackages = pkgs.buildEnv {
        name = "my-custom-packages";
        paths = [
          pkgs.linuxHeaders
        ];
      };
    };
  };

# Use the systemd-boot EFI boot loader and specify Linux kernel.
  boot = {
    # kernelPackages = pkgs.linuxPackages_latest; # Switch Kernels via appending _6_12 
    kernelPackages = pkgs.linuxPackages_6_12;
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "mem_sleep_default=s2idle" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      generic-extlinux-compatible.configurationLimit = 10;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    auto-optimise-store = true;
  };

# Network Settings
  hardware.bluetooth.enable = true;
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    wireless = {
      iwd = { # Trouble auto-connecting on tNix
        enable = true;
        settings = {
          IPv6.Enabled = false;
          Settings = { AutoConnect = true; };
        };
      };
    };
    useDHCP = lib.mkDefault true;
    firewall = { 
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedTCPPortRanges = [ 
        { from = 53317; to = 53317; } # LocalSend
      ];
      allowedUDPPortRanges = [ 
        { from = 53317; to = 53317; } # LocalSend
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

# Define a user account. 
  users.users.ca = {
    isNormalUser = true;
    extraGroups = [ "sudo" "networkmanager" "wheel" "libvirtd" "kvm"];
    linger = true;
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

# Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
    SuspendState=freeze
  '';
  
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
    logind = {
      # powerKey = "hibernate";
      # powerKeyLongPress = "poweroff";
      lidSwitch = "hibernate";
    };
    auto-cpufreq.enable = true;
    tlp.enable = true;
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
  };

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
    inputs.nvim-flake.packages.${pkgs.system}.neovim
    kitty
    lazygit
    localsend
    libqalculate
    mpv
    myCustomPackages
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
    sd
    tldr
    trash-cli
    tree
    ttyper
    unzip
    usbutils
    vifm
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
