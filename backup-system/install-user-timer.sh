#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

if [[ -r /etc/NIXOS ]]; then
  cat <<EOF
This is a NixOS system.

The user backup timer is defined declaratively in:

  /home/ca/.nixos/users/cahome.nix

Apply it with:

  sudo nixos-rebuild switch --flake /home/ca/.nixos#nNix

Then verify it with:

  systemctl --user list-timers computer-backup.timer
EOF
  exit 0
fi

mkdir -p "$SYSTEMD_USER_DIR"

sed "s#__BACKUP_ROOT__#$ROOT_DIR#g" "$ROOT_DIR/systemd/computer-backup.service" > "$SYSTEMD_USER_DIR/computer-backup.service"
sed "s#__BACKUP_ROOT__#$ROOT_DIR#g" "$ROOT_DIR/systemd/computer-backup.timer" > "$SYSTEMD_USER_DIR/computer-backup.timer"

systemctl --user daemon-reload
systemctl --user enable --now computer-backup.timer
systemctl --user list-timers computer-backup.timer
