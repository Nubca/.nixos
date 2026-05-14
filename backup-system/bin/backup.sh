#!/usr/bin/env bash
set -Eeuo pipefail

die() {
  printf 'backup: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${BACKUP_CONFIG:-$ROOT_DIR/config/backup.conf}"

[[ -r "$CONFIG_FILE" ]] || die "cannot read config: $CONFIG_FILE"
# shellcheck source=/dev/null
source "$CONFIG_FILE"

: "${BACKUP_DEST:?BACKUP_DEST must be set}"
: "${RETAIN_SNAPSHOTS:=30}"
: "${ONE_FILE_SYSTEM:=true}"

if [[ ${#BACKUP_SOURCES[@]:-0} -eq 0 ]]; then
  die "BACKUP_SOURCES must contain at least one path"
fi

command -v rsync >/dev/null 2>&1 || die "rsync is required"
command -v flock >/dev/null 2>&1 || die "flock is required"

case "$BACKUP_DEST" in
  /|"") die "BACKUP_DEST must not be / or empty" ;;
esac

SNAPSHOT_ROOT="$BACKUP_DEST/snapshots"
LOG_DIR="$BACKUP_DEST/logs"
LOCK_FILE="$BACKUP_DEST/.backup.lock"
mkdir -p "$SNAPSHOT_ROOT" "$LOG_DIR"

exec 9>"$LOCK_FILE"
flock -n 9 || die "another backup is already running"

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
NEW_SNAPSHOT="$SNAPSHOT_ROOT/$TIMESTAMP"
PARTIAL_SNAPSHOT="$SNAPSHOT_ROOT/.partial-$TIMESTAMP"
LATEST_LINK="$BACKUP_DEST/latest"
LOG_FILE="$LOG_DIR/$TIMESTAMP.log"

exec > >(tee -a "$LOG_FILE") 2>&1

cleanup_partial() {
  if [[ -d "$PARTIAL_SNAPSHOT" ]]; then
    log "removing incomplete snapshot $PARTIAL_SNAPSHOT"
    rm -rf -- "$PARTIAL_SNAPSHOT"
  fi
}
trap cleanup_partial ERR INT TERM

resolve_path() {
  local value="$1"
  if [[ "$value" = /* ]]; then
    printf '%s\n' "$value"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$value"
  fi
}

EXCLUDE_ARGS=()
if [[ -n "${EXCLUDE_FILE:-}" ]]; then
  EXCLUDE_PATH="$(resolve_path "$EXCLUDE_FILE")"
  [[ -r "$EXCLUDE_PATH" ]] || die "cannot read exclude file: $EXCLUDE_PATH"
  EXCLUDE_ARGS=(--exclude-from="$EXCLUDE_PATH")
fi

RSYNC_BASE_OPTS=(-aHAX --numeric-ids --delete --delete-excluded --info=stats2,progress2)
if [[ "$ONE_FILE_SYSTEM" == "true" ]]; then
  RSYNC_BASE_OPTS+=(--one-file-system)
fi

PREVIOUS_SNAPSHOT=""
if [[ -L "$LATEST_LINK" ]]; then
  PREVIOUS_SNAPSHOT="$(readlink -f -- "$LATEST_LINK" || true)"
fi

log "starting backup to $NEW_SNAPSHOT"
mkdir -p "$PARTIAL_SNAPSHOT"

for source in "${BACKUP_SOURCES[@]}"; do
  expanded_source="${source/#\~/$HOME}"
  [[ -e "$expanded_source" ]] || die "source does not exist: $expanded_source"

  source_name="$(printf '%s' "$expanded_source" | sed 's#^/##; s#[/[:space:]]#_#g')"
  target_dir="$PARTIAL_SNAPSHOT/$source_name"
  mkdir -p "$target_dir"

  link_dest_args=()
  if [[ -n "$PREVIOUS_SNAPSHOT" && -d "$PREVIOUS_SNAPSHOT/$source_name" ]]; then
    link_dest_args=(--link-dest="$PREVIOUS_SNAPSHOT/$source_name")
  fi

  log "syncing $expanded_source -> $target_dir"
  rsync \
    "${RSYNC_BASE_OPTS[@]}" \
    "${EXCLUDE_ARGS[@]}" \
    "${RSYNC_EXTRA_OPTS[@]:-}" \
    "${link_dest_args[@]}" \
    "$expanded_source/" \
    "$target_dir/"
done

mv -- "$PARTIAL_SNAPSHOT" "$NEW_SNAPSHOT"
ln -sfn -- "$NEW_SNAPSHOT" "$LATEST_LINK"
log "snapshot complete: $NEW_SNAPSHOT"

mapfile -t snapshots < <(find "$SNAPSHOT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.partial-*' -printf '%f\n' | sort)
snapshot_count="${#snapshots[@]}"
if (( snapshot_count > RETAIN_SNAPSHOTS )); then
  delete_count=$((snapshot_count - RETAIN_SNAPSHOTS))
  log "pruning $delete_count old snapshot(s)"
  for ((i = 0; i < delete_count; i++)); do
    rm -rf -- "$SNAPSHOT_ROOT/${snapshots[$i]}"
  done
fi

log "backup finished"
