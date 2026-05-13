# Trading VM Libvirt Config

This directory holds the versioned libvirt domain config for the Windows 11
trading VM on `nNix`.

## Files

- `config.xml`: source-of-truth libvirt domain XML for `Win11-Trading`

Operational notes live in `docs/vms/trading-vm.md`.

## Current Network

The VM is bridged onto the physical LAN through host bridge `br0`.

- XML interface type: `bridge`
- XML source: `br0`
- guest NIC model: `virtio`
- guest MAC: `52:54:00:a3:3d:9a`
- host bridge address: check with `ip -br addr show br0`

Do not change the VM back to libvirt's default NAT network for
latency-sensitive trading traffic unless this is an explicit rollback.

## Firmware State

Secure Boot is enabled in the VM XML. It was temporarily disabled during the
Scream guest driver installation, then restored.

## Workflow

Edit `config.xml` first for persistent VM hardware/config changes. Then apply
it manually:

```fish
virsh --connect qemu:///system define vms/trading/config.xml
```

The VM does not need to be shut down to define persistent XML, but changes to
hardware devices usually take effect after the next full guest shutdown and
start.

A NixOS rebuild does not automatically apply this XML. After editing
`config.xml`, run `virsh define` manually.

## Avoid Drift

Avoid changing VM hardware in virt-manager unless you immediately export the
result back into this file:

```fish
virsh --connect qemu:///system dumpxml --inactive Win11-Trading > vms/trading/config.xml
```

Use `--inactive` so the file captures persistent config instead of temporary
runtime state.

## Current Shared Folder

The VM uses an SMB share over the trading VM bridge:

- host path: `/home/ca/Downloads/vm-share`
- Windows path: `\\<host-br0-ip>\vm-share`
- Samba user: `ca`

The host directory is created by `modules/nixos/kvm-trading.nix`.
The Samba service and `br0` firewall rule are also defined there.

Run this from the normal Windows user session, not an Administrator shell:

```powershell
cmdkey /add:<host-br0-ip> /user:ca /pass
net use Z: \\<host-br0-ip>\vm-share /persistent:yes
```

The host needs a Samba password for `ca`:

```fish
sudo smbpasswd -a ca
```

Do not add a VirtIO-FS filesystem device back to this XML without retesting it
alongside Looking Glass/kvmfr. The previous attempt failed with
`vhost_set_mem_table failed` in the libvirt QEMU log.

## Before Defining

Review diffs before applying XML changes:

```fish
git diff -- vms/trading/config.xml
```

Do not apply XML changes casually when they touch GPU passthrough, CPU pinning,
firmware, TPM, storage, or PCI addresses.
