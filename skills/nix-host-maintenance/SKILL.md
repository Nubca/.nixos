---
name: nix-host-maintenance
description: Use when working on NixOS host configuration, host health checks, performance tuning, or operational changes on the nNix trading workstation. Prefer declarative fixes, read the nNix system context first, verify host health before VM tuning, and surface risk before changes affecting boot, GPU binding, VFIO, initrd, kernel parameters, display manager, or storage.
---

# Nix Host Maintenance

Read `/home/ca/.nixos/docs/systems/nNix.md` before making recommendations or
editing host configuration.

## Use this skill when

- Editing NixOS configuration for `nNix`
- Troubleshooting host stability, latency, or performance
- Reviewing changes that may affect boot, GPU binding, VFIO, initrd, kernel
  parameters, the display manager, or storage
- Preparing repeatable benchmark or validation steps

## Do not use this skill when

- The task is unrelated to NixOS host configuration
- The user only wants general Linux or Nix explanations with no `nNix`
  context

## Working rules

- Prefer declarative repo changes over imperative one-off fixes.
- Use Fish-compatible shell snippets unless Bash is explicitly requested.
- Do not prioritize Windows VM tuning until host health is confirmed.
- Explain risk before suggesting changes to boot, GPU binding, VFIO, initrd,
  kernel parameters, display manager, or storage.
- Preserve system stability over speculative tuning.

## Workflow

1. Read `docs/systems/nNix.md`.
2. Identify whether the task is host-health, host-configuration, or VM-related.
3. If the task touches risky system areas, state the risk before proposing the
   change.
4. Prefer repo-backed NixOS configuration edits over imperative commands.
5. If performance or regression claims are involved, read
   `references/benchmarking.md` and use the benchmark workflow.
6. If GPU, VFIO, boot, initrd, display, kernel, or storage is involved, read
   `references/risk-checklist.md`.
7. Read `references/rebuild-validation.md` before suggesting apply or reboot
   steps.
8. Validate changes with the narrowest safe check available before suggesting
   broader rebuild or reboot steps.

## References

- Read `references/benchmarking.md` for repeatable host benchmark usage.
- Read `references/risk-checklist.md` before high-impact system changes.
- Read `references/rebuild-validation.md` for preferred rebuild and validation
  flow on `nNix`.

## Scripts

- Use `scripts/check-host.fish` for a non-destructive host sanity sweep before
  proposing tuning changes or chasing VM-side symptoms.

## Output expectations

- Explain the proposed change in plain language.
- State the risk level if system-critical areas are involved.
- Prefer durable file edits and repeatable verification steps.
