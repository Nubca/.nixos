# ###### Special Config pNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./phardware.nix
    ../../base.nix
  ];

  environment.sessionVariables = { NH_FLAKE = "/home/ca/.nixos"; };

  networking = {
    hostName = "pNix";
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

  virtualisation.spiceUSBRedirection.enable = true;

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
      ]; 
    };

    admin = {
      isNormalUser = true;
      initialPassword = "changeme";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ57DtlRJRHHceyg00N4PIswa4/sn/zA5nCInnX1Tka" # mpNix public key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEcufvqpzURfwPzHI8uaEzLCLkNuOe/zezQfJ8uB40UE" # iNix public key
      ]; 
    };

    wa = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
  };

  services = {
    displayManager = {
      enable = true; 
      defaultSession = "qtile";
      autoLogin = {
        enable = true;
        user = "ca";
      };
    };
    # logind = {
      # powerKey = "hibernate";
      # powerKeyLongPress = "poweroff";
      # lidSwitch = "hibernate";
    # };
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

  services.printing = { 
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
  
  environment.systemPackages = with pkgs; [
    clickup
    darktable
    dosfstools
    davinci-resolve
    gimp
    gparted
    hfsprogs
    hplipWithPlugin
    inkscape
    lilypond
    mtools
    musescore
    nixd
    nodejs
    npins
    obs-studio
    python3
    telegram-desktop
    qutebrowser
    qmk
    qmk-udev-rules
    reaper
    thunderbird
  ];

 # Necessary for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}"];
 # Necessary for QMK
  hardware.keyboard.qmk.enable = true;

# DO NOT ALTER OR DELETE
  system.stateVersion = "24.05";
}
