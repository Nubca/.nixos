# nNix System Context

This machine is named nNix.

## Purpose

nNix is my primary NixOS trading workstation. It should be optimized for:

- stability
- low latency
- fast execution
- reliable GPU passthrough
- healthy host performance before VM work

## Current Hardware

- Motherboard: Asus Z390-P
- CPU: Intel i9-9900K
- Previous motherboard: MSI Z390-A Pro
- Previous CPU: Intel i9-9900
- RAM: 2x32GB Corsair Vengeance DDR4 3600MHz, part CMK64GX4M2D3600C18
- Host GPU: AMD Radeon RX 570 / RX 470-580 family, MSI Armor 8G OC
- Passthrough GPU: Nvidia GeForce GTX 1660 Ti, EVGA, bound to vfio-pci
- iGPU: Intel UHD Graphics 630, intended for OBS Studio streaming
- Storage:
  - Sabrent NVMe 238.5GB, Phison E12 controller, root/NixOS
  - 2x WDC WD10JUCT 1TB SATA drives mounted as /files1 and /files2
- Current display: Sanyo DP42D24, 40 inch, 1920x1080 at 60Hz
- OS: NixOS 26.05 x86_64
- Kernel: Linux 7.0.2 xanmod1
- Shell: Fish

## Boot / Firmware

- UEFI-only boot
- CSM disabled / not used
- PCIe set to Gen3 in BIOS
- BIOS optimizations have already been applied
- Nvidia GPU is in the primary PCIe x16 slot because the system was originally optimized for Windows VM passthrough with Looking Glass
- AMD RX 570 is the NixOS host GPU
- Intel iGPU is enabled

## Known Recent Event

A lightning strike fried the previous motherboard and at least one display. After replacing the motherboard and CPU, performance feels considerably worse even though specs should be equal or better.

The previous MSI Z390-A Pro + i9-9900 setup ran wonderfully. The current Asus Z390-P + i9-9900K system feels slower.

## Current Diagnostic Findings

### PCIe topology

Nvidia GTX 1660 Ti:

- Address: 0000:01:00.0
- Driver: vfio-pci
- LnkCap: 8GT/s, x16
- LnkSta: 2.5GT/s, x16
- Interpretation: x16 width is good. Gen1 speed may be idle/power-state related because card is bound to vfio-pci.

Nvidia functions also bound to vfio-pci:

- 0000:01:00.1 audio
- 0000:01:00.2 USB controller
- 0000:01:00.3 UCSI controller

AMD RX 570:

- Address: 0000:03:00.0
- Driver: amdgpu
- LnkCap: 8GT/s, x16
- LnkSta: 8GT/s, x4
- Interpretation: Gen3 x4 is expected because the second full-length slot on Asus Z390-P is chipset-fed x4.

Intel UHD 630:

- Address: 0000:00:02.0
- Driver: i915

NVMe:

- Address: 0000:06:00.0
- Phison E12 NVMe controller
- Current: PCIe 3.0 x4
- Max: PCIe 3.0 x4

### CPU

- Detected as Intel i9-9900K
- 8 cores / 16 threads
- Max frequency shown: 5000 MHz
- Governor: performance on all 16 logical CPUs
- intel_pstate status: active
- cpupower energy performance preference: performance
- This appears to be an intentional tuning change from a later optimization
  pass. Do not assume the older passive-mode note is still current unless the
  live system shows it again.

### RAM

- 64GB total
- Two 32GB Corsair sticks
- Configured speed: 3600 MT/s
- XMP appears active

### Warning / Error Clues

Important warnings seen:

- `/etc/modprobe.d/nixos.conf line 10: ignoring bad line starting with '#'`
- USB errors:
  - `usb device descriptor read/64, error -71`
  - `device not accepting address`
  - `unable to enumerate USB device`
- local udev rule warnings from `/etc/udev/rules.d/99-local.rules`
- `amdgpu Failed to setup vendor infoframe on connector HDMI-A-3: -22`
- `nvme nvme0: missing or invalid SUBNQN field`

Historical note:

- Earlier troubleshooting captured `intel_pstate` in passive mode with energy
  bias drift back to `normal`, but that is not the current tuned state as of
  May 12, 2026.

## Current Working Diagnosis

The GPUs do not currently look dead.

The Nvidia card is not stuck at x8; it is x16 width. The current Gen1 speed may be because it is idle and bound to vfio-pci.

The AMD card is running Gen3 x4, which is expected in the second full-length slot on this board.

The host slowness is more likely caused by one or more of:

- malformed modprobe config
- bad or noisy USB device/port/header after lightning event
- RAM/XMP instability at 3600 MT/s
- udev rule problems
- power/thermal/firmware settings
- kernel/config regression
- possible physical motherboard/port damage

## Next Commands To Run

Use Fish syntax.

```fish
sudo dmesg -T | grep -Ei "available PCIe bandwidth|limited by"
sudo sed -n '1,40p' /etc/modprobe.d/nixos.conf
sudo sed -n '1,80p' /etc/udev/rules.d/99-local.rules
