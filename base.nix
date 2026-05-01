# ----- * NixOS Default Config* - base.nix -----

{ inputs, pkgs, lib, ... }: {

# Use the systemd-boot EFI boot loader and specify Linux kernel.
  boot = {
    kernelPackages = pkgs.linuxPackages; # Switch Kernels via appending _6_12
    # kernelPackages = pkgs.linuxPackages_6_12;
    kernelParams = [
      # "mem_sleep_default=s2idle"
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

# Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

# Variables
  nixpkgs.overlays = [
  ];

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

  security = {
    polkit.enable = true;
    pam.services = {
      login.enableGnomeKeyring = true;
    };
    rtkit.enable = true;
  };

  console.useXkbConfig = true;

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    pulseaudio.enable = false;

    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    dbus.packages = [ pkgs.gcr ];
    dbus.implementation = "broker"; # Modern, faster DBus

    openssh = {
      enable = true;
      settings = {
        AllowUsers = [ "admin" ];
        PasswordAuthentication = true; # Disable password authentication for security
        PermitRootLogin = "no";         # Prohibit root login
        UseDns = false;                 # Speed up SSH connections
        ClientAliveInterval = 300;      # Keep the connection alive
        ClientAliveCountMax = 1;        # Terminate unresponsive sessions
        X11Forwarding = true;
      };
    };

    fail2ban.enable = true;

    pcscd.enable = true; # For YubiKey CCID
    udisks2.enable = true;
    devmon.enable = false;
    gvfs.enable = true;

    libinput = {
      touchpad.naturalScrolling = true;
      mouse.naturalScrolling = true;
    };

    auto-cpufreq.enable = false;

    udev = {
      packages = [ pkgs.yubikey-personalization ];
      extraRules = ''
      # Prevent Moonlander keyboard from sleeping
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", ATTR{power/control}="on"
      # Also disable autosuspend for this device
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", ATTR{power/autosuspend}="-1"
      '';
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

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  virtualisation = {
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Allows 'docker' commands
    };
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

  systemd.sleep.settings.Sleep = {
      HibernateDelaySec = "2h";
      SuspendState = "freeze";
  };

# Virtualisation
  programs = {
    virt-manager.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      clean = {
        enable = true;
        # extraArgs = "--keep 10 --keep-since 15d";
      };
    };
  };

  environment.sessionVariables = {
    NH_FLAKE = "/home/ca/.nixos";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono
    fg-virgil
    google-fonts
  ];

  xdg.mime = {
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

# Define a user account.
  users.users = {
    ca = {
      isNormalUser = true;
      extraGroups = [ "sudo" "networkmanager" "wheel" "plugdev" "libvirtd" "qemu-libvirtd" "kvm" "input" "output" "video" "audio"];
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

# Packages installed system-wide
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    awww
    audacity
    bat
    bluetuith
    bluez
    bluez-tools
    btop
    devbox
    distrobox
    dosfstools
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
    gparted
    gimp
    gnupg
    git
    hfsprogs
    hplipWithPlugin
    inputs.nvim-flake.packages.${pkgs.stdenv.system}.neovim
    kitty
    lazygit
    libqalculate
    mpv
    mtools
    nix-output-monitor
    nixd
    nodejs
    npins
    nvd
    obsidian
    obs-studio
    pwvucontrol
    pciutils
    pv
    python3
    rdfind
    ripdrag
    ripgrep
    rofi
    rofimoji
    sd
    seahorse
    tldr
    thunderbird
    tradingview
    trash-cli
    tree
    ttyper
    udiskie
    unzip
    usbutils
    vesktop
    vivaldi
    vlc
    wget
    yt-dlp
    yubikey-manager
    yubikey-personalization
    zathura
    zoxide
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}"];

}
