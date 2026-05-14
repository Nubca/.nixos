#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  restore.sh SNAPSHOT SOURCE_NAME RELATIVE_PATH RESTORE_DEST

Example:
  restore.sh 20260513-220000 home_ca Documents/report.pdf /tmp/restore

Run bin/list-backups.sh to see snapshot names. Browse BACKUP_DEST/latest to see
source names such as home_ca.
USAGE
}

if [[ $# -ne 4 ]]; then
  usage >&2
  exit 2
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${BACKUP_CONFIG:-$ROOT_DIR/config/backup.conf}"

# shellcheck source=/dev/null
source "$CONFIG_FILE"

SNAPSHOT="$1"
SOURCE_NAME="$2"
RELATIVE_PATH="${3#/}"
RESTORE_DEST="$4"

FROM="$BACKUP_DEST/snapshots/$SNAPSHOT/$SOURCE_NAME/$RELATIVE_PATH"
[[ -e "$FROM" ]] || {
  printf 'restore: path not found in backup: %s\n' "$FROM" >&2
  exit 1
}

mkdir -p "$RESTORE_DEST"
rsync -aHAX --info=stats2 "$FROM" "$RESTORE_DEST/"
printf 'Restored %s to %s\n' "$FROM" "$RESTORE_DEST"
