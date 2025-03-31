{ config, lib, pkgs, inputs, ... }:

{
  services.iwd-watchdog = {
    enable = true;
    description = "Monitor and repair WiFi connection";
    path = with pkgs; [ iwd networkmanager coreutils iproute2 gnugrep procps ];
    script = ''
      #!/bin/sh
      
      # Configuration
      INTERFACE="wlan0"
      TEST_HOST="1.1.1.1"
      LOG_FILE="/var/log/iwd-watchdog.log"
      
      log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
        echo "$1"
      }
      
      # Check if another instance is already running
      if pgrep -f "iwd-watchdog" | grep -v $$ > /dev/null; then
        log "Another instance already running, exiting"
        exit 0
      fi
      
      # Check if we can reach the internet
      if ! ping -c 2 -W 5 $TEST_HOST > /dev/null 2>&1; then
        log "Internet connection failed, attempting repair..."
        
        # Get interface status
        if ! ip link show $INTERFACE > /dev/null 2>&1; then
          log "WiFi interface $INTERFACE not found"
          exit 1
        fi
        
        # Check if interface is up
        if ! ip link show $INTERFACE | grep -q "UP"; then
          log "WiFi interface down, bringing it up..."
          ip link set $INTERFACE up
          sleep 3
        fi
        
        # Check for WiFi driver issues
        DRIVER_MODULE=$(readlink /sys/class/net/$INTERFACE/device/driver | awk -F/ '{print $NF}')
        if [ -n "$DRIVER_MODULE" ]; then
          log "Checking WiFi driver: $DRIVER_MODULE"
          # Only reload if it's a typical Intel WiFi driver
          if echo "$DRIVER_MODULE" | grep -q "iwl"; then
            log "Reloading WiFi driver module"
            rmmod $DRIVER_MODULE 2>/dev/null || true
            sleep 2
            modprobe $DRIVER_MODULE || true
            sleep 3
          fi
        fi
        
        # Force scan to refresh available networks
        log "Scanning for networks..."
        iwctl station $INTERFACE scan
        sleep 5
        
        # Get current connection status
        CONNECTION_STATUS=$(nmcli -t -f DEVICE,STATE device | grep "^$INTERFACE" | cut -d: -f2)
        
        case "$CONNECTION_STATUS" in
          disconnected)
            log "Interface disconnected, attempting to reconnect..."
            nmcli device connect $INTERFACE
            sleep 8
            ;;
          connecting)
            log "Connection in progress, waiting..."
            sleep 10
            ;;
          connected)
            log "Device shows connected but internet unreachable, refreshing connection..."
            nmcli device disconnect $INTERFACE
            sleep 3
            nmcli device connect $INTERFACE
            sleep 7
            ;;
          *)
            log "Unknown state '$CONNECTION_STATUS', restarting NetworkManager..."
            systemctl restart NetworkManager.service
            sleep 15
            ;;
        esac
        
        # Final check if internet is now working
        if ping -c 1 -W 5 $TEST_HOST > /dev/null 2>&1; then
          log "Connection successfully restored"
        else
          log "Connection still down after repair attempt"
        fi
      else
        # Everything is working - check signal quality
        SIGNAL=$(iwctl station $INTERFACE get-networks | grep -E '\*' | awk '{print $(NF-1)}' | grep -o '\-[0-9]\+')
        if [ -n "$SIGNAL" ] && [ "$SIGNAL" -lt -75 ]; then
          log "Warning: Poor signal strength: $SIGNAL dBm"
        fi
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      Restart = "no";
    };
  };

  systemd.timers.iwd-watchdog = {
    enable = true;
    description = "Run WiFi watchdog periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "60s";
      OnUnitActiveSec = "120s";  # Run every 2 minutes
      RandomizedDelaySec = "30s"; # Add randomization to prevent exact timing collisions
      AccuracySec = "30s";
    };
  };
}
