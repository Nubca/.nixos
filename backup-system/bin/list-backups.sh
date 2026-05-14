#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${BACKUP_CONFIG:-$ROOT_DIR/config/backup.conf}"

# shellcheck source=/dev/null
source "$CONFIG_FILE"

SNAPSHOT_ROOT="$BACKUP_DEST/snapshots"
if [[ ! -d "$SNAPSHOT_ROOT" ]]; then
  printf 'No snapshots found at %s\n' "$SNAPSHOT_ROOT" >&2
  exit 1
fi

find "$SNAPSHOT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.partial-*' -printf '%f\n' | sort
