{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = lib.mkDefault true;
    facetimehd.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = false;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470; 
    };
  };
  
  boot.kernelParams = [
    "nvidia-drm.modeset=0"
    "nvidia-drm.fbdev=1"
    "vga=normal"
  ];

  services.xserver.videoDrivers = ["nvidia"];
  
  nixpkgs.config = {
    nvidia.acceptLicense = true;
  };
}  
# Originally added in an attempt to create power-key-triggered menu, but I never got it to work. It's really unneeded anyway.

#   services.logind.extraConfig = ''
#     HandlePowerKey=ignore
#     PowerKeyIgnoreInhibited=yes
#   '';
#
# # Add a custom script to handle power button press
#   environment.etc."acpi/events/powerbtn".text = ''
#     event=button/power
#     action=/etc/power-menu.sh
#   '';
#
# environment.etc."power-menu.sh".text = ''
#   #!${pkgs.bash}/bin/bash
#   chosen=$(echo -e "Hibernate\nSuspend\nReboot\nPoweroff\nCancel" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Power Menu")
#   case "$chosen" in
#     Hibernate) ${pkgs.systemd}/bin/systemctl hibernate ;;
#     Suspend) ${pkgs.systemd}/bin/systemctl suspend ;;
#     Restart) ${pkgs.systemd}/bin/systemctl reboot ;;
#     Shutdown) ${pkgs.systemd}/bin/systemctl poweroff ;;
#     *) exit 0 ;;
#   esac
# '';
#
# # Make the script executable
#   environment.etc."power-menu.sh".mode = "0755";
#
#   systemd.user.services.dunst = {
#     description = "Dunst notification daemon";
#     wantedBy = [ "graphical-session.target" ];
#     partOf = [ "graphical-session.target" ];
#     serviceConfig = {
#       ExecStart = "${pkgs.dunst}/bin/dunst";
#       Restart = "always";
#       RestartSec = 3;
#     };
#   };
#
#   systemd.user.targets.graphical-session = {
#     description = "Current graphical user session";
#     wantedBy = [ "default.target" ];
#   };
