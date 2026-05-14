#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -r /etc/NIXOS ]]; then
  cat <<EOF
This is a NixOS system with a read-only /etc systemd unit path.

The VM backup timer has been added declaratively to:

  /home/ca/.nixos/modules/nixos/kvm-trading.nix

Apply it with:

  sudo nixos-rebuild switch --flake /home/ca/.nixos#nNix

Then verify it with:

  systemctl list-timers win11-trading-backup.timer
EOF
  exit 0
fi

if (( EUID != 0 )); then
  exec sudo "$0" "$@"
fi

sed "s#__BACKUP_ROOT__#$ROOT_DIR#g" "$ROOT_DIR/systemd/win11-trading-backup.service" > /etc/systemd/system/win11-trading-backup.service
sed "s#__BACKUP_ROOT__#$ROOT_DIR#g" "$ROOT_DIR/systemd/win11-trading-backup.timer" > /etc/systemd/system/win11-trading-backup.timer

systemctl daemon-reload
systemctl enable --now win11-trading-backup.timer
systemctl list-timers win11-trading-backup.timer
