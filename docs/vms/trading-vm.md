# Trading VM Operations

This document holds repeatable operational notes for the trading VM on `nNix`.

Keep host-health context in `docs/systems/nNix.md`.
Keep host benchmarking workflow in `docs/benchmarking/README.md`.
Put guest-facing setup and VM-specific runtime procedures here.

## Scope

Use this document for:

- Windows guest integration steps
- guest audio, display, and input workflow
- libvirt guest network assumptions that the VM depends on
- repeatable VM-side operational notes

Do not use this document for:

- transient troubleshooting logs
- one-off command output
- host hardware diagnosis
- benchmark result captures

## Scream Audio

Scream is used for Windows guest audio from the trading VM back to the NixOS
host.

The current production path is network Scream over the bridged LAN, not
ivshmem audio and not libvirt NAT.

### Host-side expectations

- The receiver runs as a `systemd --user` service named `scream`.
- The receiver listens on UDP port `4010`.
- The receiver is bound to `br0` with `scream -o pulse -u -i br0 -p 4010`.
- NixOS firewall access is opened on the trading VM bridge `br0`.
- The host-side receiver is defined in `modules/nixos/kvm-trading.nix`.

### Guest-side expectations

- Use the Scream Windows virtual audio driver in the trading VM.
- Configure the sender to use unicast UDP to the host's `br0` LAN address on
  port `4010`.
- The guest address is assigned by the physical LAN DHCP server. As of the
  bridge migration session, the guest was observed at `192.168.1.41`.

### Windows guest setup checklist

1. Install the Scream virtual audio driver in the VM.
2. Install or configure the Scream sender or service for unicast UDP to
   `<host-br0-ip>:4010`.
3. Reboot the VM if the driver install requires it.
4. In Windows Sound settings, select the Scream device as the default output
   while testing guest audio.
5. On the host, confirm the `scream` user service is active before debugging
   guest audio routing.

### Validation

When audio is not working, verify the stack in this order:

1. Confirm the VM is still using the expected `br0` bridge network path.
2. Confirm the Windows guest is targeting `<host-br0-ip>:4010`.
3. Confirm the host `scream` user service is running.
4. Confirm PipeWire audio on the host is otherwise healthy.
5. Only after that, debug guest driver or Windows audio device selection.

Useful host checks:

```fish
ip -br addr show br0
systemctl --user status scream --no-pager
ss -lunp | rg ':4010|scream'
```

Useful Windows checks:

```powershell
Test-NetConnection <host-br0-ip> -Port 4010 -InformationLevel Detailed
```

UDP audio will not prove delivery with a TCP-style connection result, but this
still confirms that Windows is targeting the expected host address.

### Secure Boot Note

Secure Boot is normally enabled for `Win11-Trading`. It was temporarily disabled
to install the Scream guest driver, then re-enabled in `vms/trading/config.xml`.
Do not leave Secure Boot disabled unless a driver-install task explicitly needs
that temporary state.

## Shared Host Folder

Use a dedicated folder inside the host Downloads directory for moving files
between the NixOS host and Windows guest:

- Host path: `/home/ca/Downloads/vm-share`
- Recommended guest drive label: `VMShare`
- Windows path: `\\<host-br0-ip>\vm-share`

Do not share the whole host Downloads directory by default. Keeping the VM share
as a subfolder preserves the convenience of Downloads while avoiding accidental
guest access to unrelated downloaded files.

### Host-side expectations

- The shared directory is created by `modules/nixos/kvm-trading.nix` with owner
  `ca` and group `libvirtd`.
- The host exports this folder with Samba over the trading VM bridge only.
- NixOS firewall access for SMB is opened on `br0`.
- Find the current host target address with `ip -br addr show br0`.

### Windows guest setup checklist

1. Open File Explorer or PowerShell in the Windows guest.
2. Connect to `\\<host-br0-ip>\vm-share`.
3. Authenticate as Samba user `ca`.
4. Optionally map it to a stable drive letter such as `Z:`.
5. Use that shared folder for installers, Scream files, VM notes, and Codex CLI
   handoff files.

Persistent mapping example. Run this from the normal Windows user session, not
an Administrator shell, so Explorer sees the same mapped drive:

```powershell
cmdkey /add:<host-br0-ip> /user:ca /pass
net use Z: \\<host-br0-ip>\vm-share /persistent:yes
```

The `cmdkey` command prompts for the Samba password and stores it in Windows
Credential Manager.

The host needs a Samba password for `ca`:

```fish
sudo smbpasswd -a ca
```

### VirtIO-FS Status

VirtIO-FS is not currently used for this VM. With the current Looking
Glass/kvmfr setup, libvirt logs showed repeated failures like
`vhost_set_mem_table failed: Input/output error (5)` and `Error starting vhost`.
That means the guest can see a VirtIO-FS device, but QEMU cannot establish the
host vhost-user memory path reliably.

Keep the VM XML free of VirtIO-FS filesystem devices unless a newer virtiofsd
or a changed Looking Glass memory path is tested and documented.

### Troubleshooting

If the share does not appear in Windows:

1. Confirm the Windows guest is on the `br0` bridge network.
2. Confirm the guest can reach the host's `br0` LAN address.
3. Confirm the NixOS Samba service is running on the host.
4. Confirm TCP port `445` is allowed on `br0`.
5. Connect directly to `\\<host-br0-ip>\vm-share`; do not rely on Windows
   network discovery.
6. Confirm the `ca` Samba account exists if Windows rejects credentials.

Useful host checks:

```fish
systemctl status smb.service
sudo ss -ltnp | rg ':445'
virsh --connect qemu:///system domifaddr Win11-Trading
```

Useful Windows checks from PowerShell:

```powershell
Test-NetConnection <host-br0-ip> -Port 445
Test-Path '\\<host-br0-ip>\vm-share'
net use
cmdkey /list:<host-br0-ip>
```

## Related Host Components

- `modules/nixos/kvm-trading.nix`
- `docs/systems/nNix.md`
