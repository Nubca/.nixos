# modules/rofi-logout.nix
{ config, lib, pkgs, ... }:

let
  rofi-logout-script = pkgs.writeShellScriptBin "rofi-logout" ''
    #!/bin/sh
    CHOICE=$(echo -e "Lock\nLogout\nSuspend\nReboot\nShutdown" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Power Menu")
    case "$CHOICE" in
      Lock) ${pkgs.slock}/bin/slock ;;
      Logout) qtile cmd-obj -o cmd -f shutdown ;;
      Suspend) systemctl suspend ;;
      Reboot) systemctl reboot ;;
      Shutdown) systemctl poweroff ;;
    esac
  '';
in {
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-soft";  # Theme name from rofi-themes package
  };

  home.packages = [ rofi-logout-script ];

  xdg.configFile."rofi/logout.rasi".text = ''
    configuration {
      font: "Fira Code 12";
      width: 20%;
    }
  '';
}
