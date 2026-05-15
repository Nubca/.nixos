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
: "${MIN_FREE_SPACE:=50G}"

if ((${#BACKUP_SOURCES[@]} == 0)); then
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

size_to_bytes() {
  local value="$1"
  local number unit

  number="${value%[KkMmGgTt]}"
  unit="${value:${#number}}"
  [[ "$number" =~ ^[0-9]+$ ]] || die "invalid size value: $value"

  case "$unit" in
    "") printf '%s\n' "$number" ;;
    [Kk]) printf '%s\n' $((number * 1024)) ;;
    [Mm]) printf '%s\n' $((number * 1024 * 1024)) ;;
    [Gg]) printf '%s\n' $((number * 1024 * 1024 * 1024)) ;;
    [Tt]) printf '%s\n' $((number * 1024 * 1024 * 1024 * 1024)) ;;
    *) die "invalid size suffix in: $value" ;;
  esac
}

available_bytes() {
  local path="$1"
  df --output=avail -B1 "$path" | tail -n 1 | tr -dc '0-9'
}

prune_snapshots() {
  local reserve_new="${1:-0}"
  local keep_count delete_count snapshot_count

  keep_count=$((RETAIN_SNAPSHOTS - reserve_new))
  if (( keep_count < 0 )); then
    keep_count=0
  fi

  mapfile -t snapshots < <(find "$SNAPSHOT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.partial-*' -printf '%f\n' | sort)
  snapshot_count="${#snapshots[@]}"
  if (( snapshot_count > keep_count )); then
    delete_count=$((snapshot_count - keep_count))
    log "pruning $delete_count old snapshot(s)"
    for ((i = 0; i < delete_count; i++)); do
      rm -rf -- "$SNAPSHOT_ROOT/${snapshots[$i]}"
    done
  fi
}

require_free_space() {
  local required="$1"
  local available

  available="$(available_bytes "$BACKUP_DEST")"
  if (( available < required )); then
    die "not enough free space at $BACKUP_DEST: available ${available} bytes, required ${required} bytes"
  fi
  log "free space check passed at $BACKUP_DEST: available ${available} bytes, required ${required} bytes"
}

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

log "pre-run pruning"
prune_snapshots 1
require_free_space "$(size_to_bytes "$MIN_FREE_SPACE")"

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
  rsync_args=(
    "${RSYNC_BASE_OPTS[@]}"
    "${EXCLUDE_ARGS[@]}"
  )
  if ((${#RSYNC_EXTRA_OPTS[@]} > 0)); then
    rsync_args+=("${RSYNC_EXTRA_OPTS[@]}")
  fi
  rsync_args+=(
    "${link_dest_args[@]}"
    "$expanded_source/"
    "$target_dir/"
  )
  rsync "${rsync_args[@]}"
done

mv -- "$PARTIAL_SNAPSHOT" "$NEW_SNAPSHOT"
ln -sfn -- "$NEW_SNAPSHOT" "$LATEST_LINK"
log "snapshot complete: $NEW_SNAPSHOT"

prune_snapshots 0

log "backup finished"
