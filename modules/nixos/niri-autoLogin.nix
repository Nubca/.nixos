{ config, pkgs, lib, ... }:

let
  niriSessionScript = ''
    #!/bin/sh
    export XDG_SESSION_TYPE=wayland
    export WAYLAND_DISPLAY=wayland-0
    exec /path/to/niri
  '';
in {
  # Enable automatic loginservices.getty.autologinUser on tty1 for the user


  # Create a systemd service unit that runs your Niri session on tty1 login
  # systemd.services.niri-session = {
  #   description = "Start Niri Wayland Session on tty1";
  #   after = [ "getty@tty1.service" ];
  #   requires = [ "getty@tty1.service" ];
  #   wants = [ "getty@tty1.service" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.bash}/bin/bash -c '${niriSessionScript}'";
  #     Restart = "always";
  #     StandardInput = "tty";
  #     StandardOutput = "tty";
  #     TTYPath = "/dev/tty1";
  #     TTYReset = true;
  #     TTYVHangup = true;
  #     TTYVTDisallocate = true;
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # Ensure the niri-session service starts at boot
  # systemd.targets.graphical.wants = [ "niri-session.service" ];

  # Include any necessary packages or environment setup here
  # environment.systemPackages = with pkgs; [ niri bash ];
}
