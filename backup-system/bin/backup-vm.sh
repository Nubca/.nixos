#!/usr/bin/env bash
set -Eeuo pipefail

die() {
  printf 'backup-vm: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${VM_BACKUP_CONFIG:-$ROOT_DIR/config/vm-backup.conf}"

[[ -r "$CONFIG_FILE" ]] || die "cannot read config: $CONFIG_FILE"
# shellcheck source=/dev/null
source "$CONFIG_FILE"

: "${VM_NAME:?VM_NAME must be set}"
: "${VM_BACKUP_DEST:?VM_BACKUP_DEST must be set}"
: "${VM_RETAIN_SNAPSHOTS:=2}"
: "${VM_SKIP_RUNNING:=true}"

(( EUID == 0 )) || die "run as root so VM disk and libvirt state are readable"

command -v rsync >/dev/null 2>&1 || die "rsync is required"
command -v flock >/dev/null 2>&1 || die "flock is required"

SNAPSHOT_ROOT="$VM_BACKUP_DEST/snapshots"
LOG_DIR="$VM_BACKUP_DEST/logs"
LOCK_FILE="$VM_BACKUP_DEST/.backup.lock"
mkdir -p "$SNAPSHOT_ROOT" "$LOG_DIR"

exec 9>"$LOCK_FILE"
flock -n 9 || die "another VM backup is already running"

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
NEW_SNAPSHOT="$SNAPSHOT_ROOT/$TIMESTAMP"
PARTIAL_SNAPSHOT="$SNAPSHOT_ROOT/.partial-$TIMESTAMP"
LATEST_LINK="$VM_BACKUP_DEST/latest"
LOG_FILE="$LOG_DIR/$TIMESTAMP.log"

exec > >(tee -a "$LOG_FILE") 2>&1

cleanup_partial() {
  if [[ -d "$PARTIAL_SNAPSHOT" ]]; then
    log "removing incomplete snapshot $PARTIAL_SNAPSHOT"
    rm -rf -- "$PARTIAL_SNAPSHOT"
  fi
}
trap cleanup_partial ERR INT TERM

vm_state="unknown"
if command -v virsh >/dev/null 2>&1; then
  vm_state="$(virsh --connect qemu:///system domstate "$VM_NAME" 2>/dev/null || true)"
fi

case "$vm_state" in
  ""|"shut off"|"shutoff")
    log "$VM_NAME is powered off; starting VM backup"
    ;;
  "unknown")
    log "could not determine VM state with virsh; checking for a running QEMU process"
    if pgrep -af "qemu-system.*$VM_NAME" >/dev/null 2>&1; then
      if [[ "$VM_SKIP_RUNNING" == "true" ]]; then
        log "$VM_NAME appears to be running; skipping backup"
        exit 0
      fi
      die "$VM_NAME appears to be running"
    fi
    ;;
  *)
    if [[ "$VM_SKIP_RUNNING" == "true" ]]; then
      log "$VM_NAME state is '$vm_state'; skipping backup"
      exit 0
    fi
    die "$VM_NAME must be powered off; current state is '$vm_state'"
    ;;
esac

mkdir -p "$PARTIAL_SNAPSHOT"

copy_path() {
  local src="$1"
  local dest="$2"

  [[ -e "$src" ]] || die "required path is missing: $src"
  mkdir -p "$(dirname -- "$dest")"
  log "copying $src"
  rsync -aHAX --sparse --numeric-ids --info=stats2 "$src" "$dest"
}

copy_optional_path() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    log "optional path not present; skipping $src"
    return
  fi

  mkdir -p "$(dirname -- "$dest")"
  log "copying optional $src"
  rsync -aHAX --sparse --numeric-ids --info=stats2 "$src" "$dest"
}

copy_path "$VM_DISK" "$PARTIAL_SNAPSHOT/var/lib/libvirt/images/$(basename -- "$VM_DISK")"
copy_path "$VM_NVRAM" "$PARTIAL_SNAPSHOT/var/lib/libvirt/qemu/nvram/$(basename -- "$VM_NVRAM")"
copy_path "$VM_XML" "$PARTIAL_SNAPSHOT/home/ca/.nixos/vms/trading/$(basename -- "$VM_XML")"

for optional_path in "${VM_OPTIONAL_PATHS[@]:-}"; do
  rel="${optional_path#/}"
  copy_optional_path "$optional_path" "$PARTIAL_SNAPSHOT/$rel"
done

mv -- "$PARTIAL_SNAPSHOT" "$NEW_SNAPSHOT"
ln -sfn -- "$NEW_SNAPSHOT" "$LATEST_LINK"
log "VM snapshot complete: $NEW_SNAPSHOT"

mapfile -t snapshots < <(find "$SNAPSHOT_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.partial-*' -printf '%f\n' | sort)
snapshot_count="${#snapshots[@]}"
if (( snapshot_count > VM_RETAIN_SNAPSHOTS )); then
  delete_count=$((snapshot_count - VM_RETAIN_SNAPSHOTS))
  log "pruning $delete_count old VM snapshot(s)"
  for ((i = 0; i < delete_count; i++)); do
    rm -rf -- "$SNAPSHOT_ROOT/${snapshots[$i]}"
  done
fi

log "VM backup finished"
