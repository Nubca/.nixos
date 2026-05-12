# Codex Instructions for nNix

This repository contains the NixOS configuration for `nNix`, a trading
workstation.

## Core Guidance

- Always read [docs/systems/nNix.md](/home/ca/.nixos/docs/systems/nNix.md:1)
  before making recommendations for this host.
- The user uses Fish shell. Shell snippets should be Fish-compatible unless
  Bash is explicitly requested.
- Prefer declarative NixOS configuration changes over imperative one-off fixes.
- Do not prioritize the Windows VM until host system health is confirmed.
- When troubleshooting, preserve system stability and explain risk before
  suggesting changes that affect:
  - boot
  - GPU binding
  - VFIO
  - initrd
  - kernel parameters
  - display manager
  - storage
- The desired end result is a system fully optimized without cutting corners.

## Durable Project Context

- `nNix` is the primary NixOS trading workstation.
- Host-first diagnosis is required before VM tuning changes are trusted.
- Benchmarking workflow is documented in
  [docs/benchmarking/README.md](/home/ca/.nixos/docs/benchmarking/README.md:1).
- Repeatable host benchmark scripts live in:
  - [scripts/benchmark-host.fish](/home/ca/.nixos/scripts/benchmark-host.fish:1)
  - [scripts/compare-benchmarks.fish](/home/ca/.nixos/scripts/compare-benchmarks.fish:1)
- Saved benchmark logs belong under `docs/benchmarking/` and include the host
  name in the filename so the workflow can be reused across multiple systems.

## Notes For Future Work

- Avoid storing transient command output, journal dumps, or one-off diagnostic
  captures in this file.
- Put durable host context in `docs/systems/nNix.md`.
- Put repeatable operational workflow in `docs/benchmarking/README.md` or other
  repo documentation instead of appending session transcripts here.
