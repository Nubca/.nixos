# ###### Special Config mpNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./mphardware.nix
    ../../modules/nixos/nvidia-mac.nix
    ./mpdisko.nix
    ../../base.nix
  ];

  networking.hostName = "mpNix";
  virtualisation.spiceUSBRedirection.enable = true;

## The below does not seem to work. Manually started.
  systemd = {
    services.systemd-logind.enable = true;
    user.services.window_logger = {
      enable = true;
      description = "Log active window";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.python3}/bin/python3 ${config.users.users.ca.home}/TimeLog/window_logger.py";
        Restart = "on-failure";
        RestartSec = "10";
        Environment = [
          "DISPLAY=:0"
          "XDG_RUNTIME_DIR=/run/user/1000"
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
         ]; 
        # PathExists = "/run/current-system/sw/bin/xprop"; # Bad Option
        WorkingDirectory = "${config.users.users.ca.home}/TimeLog";
      };
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "ca" = import ../../users/cahome.nix; };
  };

  services.displayManager = {
    enable = true; 
    defaultSession = "qtile";
    autoLogin = {
      enable = true;
      user = "ca";
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

  services.printing = { 
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
  
  environment.systemPackages = with pkgs; [
    clickup
    darktable
    dosfstools
    davinci-resolve
    gparted
    gimp-with-plugins
    hfsprogs
    hplipWithPlugin
    inkscape-with-extensions
    mtools
    nixd
    npins
    obs-studio
    python3
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
