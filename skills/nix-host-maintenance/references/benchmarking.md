# Benchmarking

Use the existing repo benchmark workflow instead of ad hoc performance
judgments.

Primary docs:

- `/home/ca/.nixos/docs/benchmarking/README.md`
- `/home/ca/.nixos/scripts/benchmark-host.fish`
- `/home/ca/.nixos/scripts/compare-benchmarks.fish`
- `../scripts/check-host.fish`

Default approach on `nNix`:

1. Capture a host-only baseline before tuning.
2. Change one lever at a time.
3. Reboot before comparison if the change touched kernel params, drivers, IRQ
   policy, or CPU power policy.
4. Run the same benchmark flow again as a candidate.
5. Compare saved logs rather than relying on system feel alone.
6. For VM-sensitive work, validate host-only first and VM-loaded second.

Run `check-host.fish` before benchmarking if the system may have a basic host
health issue such as CPU policy drift, broken device state, or obvious kernel
warnings.

Saved logs belong under `docs/benchmarking/` and should include the host name
in the filename.
