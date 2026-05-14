# Computer Backup System

This is a local automated backup system built on `rsync` snapshots.

It has two independent jobs:

- daily user-data snapshots from `/home/ca` and the real `/files1` symlink
  targets
- separate `Win11-Trading` VM snapshots, only when the VM is powered off

## What It Does

- Backs up configured paths from `config/backup.conf`.
- Stores timestamped snapshots under `/files2/backups/<hostname>/snapshots/`.
- Maintains a `latest` symlink for quick browsing.
- Uses hard links against the previous snapshot, so unchanged files do not take
  full duplicate space.
- Keeps the newest `RETAIN_SNAPSHOTS` snapshots.
- Runs user-data backups daily at about 16:00 Central through a systemd user timer
  after installation.
- Keeps only two VM snapshots by default because the VM disk is large.

## Configure

Edit `config/backup.conf`.

Important settings:

- `BACKUP_DEST`: destination directory for snapshots.
- `BACKUP_SOURCES`: paths to back up. The default includes `/home/ca` plus
  `/files1/Documents`, `/files1/Sources`, `/files1/Pictures`, `/files1/Music`,
  and `/files1/Videos`.
- `RETAIN_SNAPSHOTS`: number of snapshots to keep.
- `EXCLUDE_FILE`: exclude patterns.

The VM backup is configured in `config/vm-backup.conf`.

## Run User Backup Once

```bash
/home/ca/.nixos/backup-system/bin/backup.sh
```

## Enable Automatic Backups On NixOS

Both timers are declared in the `.nixos` repo:

- user-data backup: `users/cahome.nix`
- VM backup: `modules/nixos/kvm-trading.nix`

Apply them with:

```bash
sudo nixos-rebuild switch --flake /home/ca/.nixos#nNix
```

Then check:

```bash
systemctl --user list-timers computer-backup.timer
systemctl list-timers win11-trading-backup.timer
```

## Enable Automatic User Backups On Non-NixOS

```bash
/home/ca/.nixos/backup-system/install-user-timer.sh
```

Check the timer:

```bash
systemctl --user list-timers computer-backup.timer
```

Run a backup immediately through systemd:

```bash
systemctl --user start computer-backup.service
```

View logs:

```bash
journalctl --user -u computer-backup.service
```

The script also writes logs under:

```bash
/files2/backups/<hostname>/logs/
```

## VM Backups

The `Win11-Trading` VM remains on the NVMe:

```text
/var/lib/libvirt/images/Win11-Trading.raw
```

The VM backup script also saves:

```text
/var/lib/libvirt/qemu/nvram/Win11-Trading_VARS.fd
/home/ca/.nixos/vms/trading/config.xml
```

Run a VM backup manually after fully shutting down Windows:

```bash
sudo /home/ca/.nixos/backup-system/bin/backup-vm.sh
```

Enable the weekly root-level VM timer on non-NixOS. It runs Saturday at about
14:00 Central:

```bash
/home/ca/.nixos/backup-system/install-vm-system-timer.sh
```

If the VM is running, the scheduled job logs a skip and leaves the VM alone.

## List Backups

```bash
/home/ca/.nixos/backup-system/bin/list-backups.sh
```

## Restore

You can browse files directly:

```bash
ls /files2/backups/<hostname>/latest
```

Or restore a specific path:

```bash
/home/ca/.nixos/backup-system/bin/restore.sh SNAPSHOT SOURCE_NAME RELATIVE_PATH RESTORE_DEST
```

Example:

```bash
/home/ca/.nixos/backup-system/bin/restore.sh 20260513-031500 home_ca Documents/report.pdf /tmp/restore
```

## Notes

- The timer runs as your user, so it cannot back up unreadable system files.
- For stronger protection, point `BACKUP_DEST` at an external disk or mounted
  network share.
- Periodically test restores. A backup system is only useful if restores work.
