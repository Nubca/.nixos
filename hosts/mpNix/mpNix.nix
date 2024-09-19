# ###### Special Config mpNix.nix #######

{ config, inputs, lib, pkgs, modulesPath, home-manager, ... }:

{
  imports = [
    ./mphardware.nix
    ../../modules/nixos/nvidia-mac.nix
    inputs.disko.nixosModules.default
    (import ./mpdisko.nix { device = "/dev/sda"; })
    ../../base.nix
  ];

  networking.hostName = "mpNix";
  virtualisation.spiceUSBRedirection.enable = true;

## The below does not seem to work. Manually started.
  systemd.user = {
    services.window_logger = {
      description = "Log active window";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.python3}/bin/python3 ${config.users.users.ca.home}/TimeLog/window_logger.py";
        Restart = "always";
        RestartSec = "10";
      };
      wantedBy = [ "default.target"];
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

  environment.systemPackages = with pkgs; [
    clickup
    obs-studio
    python3
    qmk
    qmk-udev-rules
    thunderbird
  ];

 # Necessary for QMK
  hardware.keyboard.qmk.enable = true;
}
