# Rebuild And Validation

Prefer the narrowest safe apply path that still proves the change.

Use Fish-compatible commands.

## Default sequence

1. Review the scope of the change and state whether it affects boot, VFIO, GPU
   binding, initrd, kernel parameters, the display path, or storage.
2. If the change is high-impact, prefer a build-first step before applying it.
3. Apply with the least risky `nixos-rebuild` mode that still validates the
   change.
4. Run focused post-change checks immediately after apply.
5. If the change is performance-sensitive, capture before and after benchmarks.

## Preferred commands

For a build-only validation:

```fish
sudo nixos-rebuild build --flake /home/ca/.nixos#nNix
```

For a temporary runtime validation that should not become the next boot target:

```fish
sudo nixos-rebuild test --flake /home/ca/.nixos#nNix
```

For a normal persistent apply when the risk is understood and acceptable:

```fish
sudo nixos-rebuild switch --flake /home/ca/.nixos#nNix
```

For boot-critical or reboot-required changes where you want the new generation
to activate on next boot instead of mutating the current session first:

```fish
sudo nixos-rebuild boot --flake /home/ca/.nixos#nNix
```

## How to choose

- Use `build` first for risky edits or when you mainly need evaluation and
  build confidence.
- Use `test` for service, desktop, or runtime behavior checks when a reboot is
  not required.
- Use `switch` for ordinary declarative changes that should apply now and
  persist.
- Use `boot` for kernel, initrd, bootloader, GPU-binding, VFIO, or storage
  changes where a reboot is part of correct validation.

## Post-apply validation

After `test` or `switch`, prefer a focused check set:

```fish
fish /home/ca/.codex/skills/nix-host-maintenance/scripts/check-host.fish
systemctl --failed
```

If the change touched a specific service, validate that service directly.

If the change touched kernel params, CPU policy, IRQ policy, drivers, GPU
binding, VFIO, or initrd:

- expect a reboot to be part of real validation
- let the machine settle for 2-5 minutes after boot
- then run host checks and benchmarks again

## Benchmark follow-through

For performance work on `nNix`, use:

```fish
~/.nixos/scripts/benchmark-host.fish current-good
~/.nixos/scripts/benchmark-host.fish candidate
~/.nixos/scripts/compare-benchmarks.fish \
  benchmark-nNix-current-good-<timestamp>.txt \
  benchmark-nNix-candidate-<timestamp>.txt
```

Do not treat subjective feel alone as proof that a tuning change helped.
