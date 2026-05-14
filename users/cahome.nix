{ config, pkgs, lib, home-manager, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "ca";
    homeDirectory = lib.mkForce "/home/ca";

    sessionVariables = { };

    packages = [ ];

    file = {
      ".config/qtile/0-Monitor.jpg".source = ../qtile/0-Monitor.jpg;
      ".config/qtile/1-Main.jpg".source = ../qtile/1-Main.jpg;
      ".config/qtile/autostart.sh".source = ../qtile/autostart.sh;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Curtis Abbott";
          email = "inspiredplans@gmail.com";
        };
      };
      signing.format = null;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  systemd.user.services.computer-backup = {
    Unit = {
      Description = "Computer rsync snapshot backup";
      Documentation = "file:///home/ca/.nixos/backup-system/README.md";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "/home/ca/.nixos/backup-system/bin/backup.sh";
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.user.timers.computer-backup = {
    Unit.Description = "Run computer backup daily";
    Timer = {
      OnCalendar = "*-*-* 16:00:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
      Unit = "computer-backup.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
