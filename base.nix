# ----- * NixOS Default Config* - base.nix -----

{ inputs, pkgs, lib, ... }: {
  imports = [ ];

# Variables
  environment.sessionVariables = { FLAKE = "/home/ca/.nixos"; };

# Use the systemd-boot EFI boot loader and specify Linux kernel.
  boot = {
    kernelPackages = pkgs.linuxPackages; # Switch Kernels via appending _6_10 etc.
    kernelParams = [ "mem_sleep_default=s2idle" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      generic-extlinux-compatible.configurationLimit = 10;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
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
      allowedTCPPortRanges = [ 
        { from = 53317; to = 53317; } # LocalSend
      ];
      allowedUDPPortRanges = [ 
        { from = 53317; to = 53317; } # LocalSend
      ];  
    };  
  };

# Enable X11 and Desktop Environment
  services = {
    xserver = {
      enable = true;
      autorun = false;
      windowManager.qtile = { enable = true; };
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
      excludePackages = with pkgs; [ xterm ];
    };

    libinput = {
      touchpad.naturalScrolling = true;
      mouse.naturalScrolling = true;
    };
  };
    
# Enable sound.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
  
# Misc. Services 
  services = {
    logind = {
      powerKey = "hibernate";
      powerKeyLongPress = "poweroff";
      lidSwitch = "suspend";
    };
    auto-cpufreq.enable = true;
    tlp.enable = true;
    upower = {
      enable = true;
      # ignoreLid = true;
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
  };

# Fonts
  fonts.packages = with pkgs; [
    nerdfonts
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
        "application/pdf" = "${pkgs.zathura}/bin/zathura %F";
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
    eza
    fastfetch
    fd
    feh
    ffmpeg
    file
    fish
    flameshot
    fzf
    git
    inputs.nvim-flake.packages.${pkgs.system}.neovim
    kitty
    lazygit
    localsend
    libqalculate
    mpv
    nh
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
