# nNix Benchmark Workflow

This directory documents the repeatable host benchmark process.

The goal is to reduce tuning by impression and replace it with before/after
measurements whenever kernel, CPU policy, IRQ placement, storage, or VM-host
coordination changes.

Saved benchmark logs are stored in `docs/benchmarking/` and include the host
name in the filename so the same workflow can be used across multiple machines.

## Scripts

- `scripts/benchmark-host.fish`
  Runs the current host benchmark in a fixed order:
  - `cpupower frequency-info`
  - `cpupower idle-info`
  - `sysbench cpu`
  - `sysbench memory`
  - `fio` 4k random-read against a temporary file in `/tmp`
  - `sensors`
  - automatically saves the full log under `docs/benchmarking/`
  - default filename format:
    `benchmark-<hostname>-<label>-<YYYYmmdd-HHMMSS>.txt`

- `scripts/compare-benchmarks.fish`
  Compares two saved benchmark logs and prints a compact before/after summary.
  It accepts either full paths or filenames already stored in
  `docs/benchmarking/`.

## Typical Usage

Run and save a general snapshot:

```fish
~/.nixos/scripts/benchmark-host.fish
```

Run and save a candidate result after a change:

```fish
~/.nixos/scripts/benchmark-host.fish candidate
```

Compare them:

```fish
~/.nixos/scripts/compare-benchmarks.fish \
  benchmark-nNix-current-good-20260511-010000.txt \
  benchmark-nNix-candidate-20260511-013000.txt
```

Capture and keep a known-good reference after the system reaches a state you are
happy with:

```fish
~/.nixos/scripts/benchmark-host.fish current-good
```

Optionally override the output path:

```fish
~/.nixos/scripts/benchmark-host.fish current-good \
  ~/.nixos/docs/benchmarking/benchmark-nNix-current-good-manual.txt
```

## When To Use It

Use this workflow:

- before and after kernel parameter changes
- before and after CPU governor, `intel_pstate`, or C-state changes
- before and after IRQ affinity or irqbalance changes
- before and after storage-related tuning
- before and after VM-host performance tuning that may affect the host

Also use it any time the machine starts to "feel slower" and you want to know
whether the issue is:

- CPU throughput
- memory behavior
- storage latency
- thermal behavior
- idle-state policy

## How To Get Trustworthy Results

- Reboot before each comparison run if the change touched kernel params, IRQ
  policy, drivers, or CPU power policy.
- Let the system sit mostly idle for 2-5 minutes after boot before starting.
- Change one performance lever at a time whenever possible.
- Keep the environment consistent:
  - same displays
  - same important peripherals
  - same VM on or off state
  - no large downloads or package builds
- Let `benchmark-host.fish` save the log automatically, or provide an explicit
  output path as the second argument if you want to control the filename.
- Compare multiple metrics together. Do not overreact to one small change.
- For important tuning changes, run the benchmark twice and compare both runs.
- Prefer clear labels such as `current-good`, `candidate`, `irqaffinity`,
  `active-pstate`, `no-cstate-cap`, `vm-load`, or `snapshot`.

## How To Interpret Results

General guidance:

- `sysbench cpu`
  Higher is better.

- `sysbench memory`
  Higher is better.

- `fio randread`
  Higher IOPS is better.
  Lower average latency is better.

- `sensors`
  Lower temperatures at equal or better performance are usually better.

- `cpupower idle-info`
  Use this to confirm whether a tuning change is forcing unusually shallow idle
  states or allowing a more normal Intel idle-state range.

## Host-Only vs VM-Loaded Runs

For `nNix`, use two benchmark modes when needed:

- host-only
  Trading VM off. Good for isolating host regressions.

- host-under-vm-load
  Trading VM on with a realistic workload. Good for checking whether a change
  preserves the VM-first design while keeping the host acceptable.

Name saved logs clearly, for example:

- `benchmark-nNix-current-good-20260511-020000.txt`
- `benchmark-nNix-candidate-20260511-021500.txt`
- `benchmark-nNix-snapshot-20260511-190000.txt`
- `benchmark-mpNix-vm-load-20260512-180000.txt`

## Recommended nNix Workflow

Use this order on `nNix`:

1. Boot the machine and let it settle for 2-5 minutes.
2. If you already have a stable preferred state, keep a `current-good` log for it.
3. Run a host-only benchmark and save it with a meaningful label if needed.
4. Make one tuning change.
5. Reboot if the change touched kernel params, CPU policy, IRQ policy, or
   drivers.
6. Run the same benchmark again and save it as a `candidate` or another clear
   experiment label.
7. Compare the `current-good` log against the `candidate` log with
   `compare-benchmarks.fish`.
8. Keep the change only if the metrics and practical behavior both support it.
9. If the new state wins, save a fresh `current-good` log.

The key distinction is:

- `current-good`
  Your rolling best known stable reference point.

- `candidate`
  The result of a new experiment you are testing against `current-good`.

- `snapshot`
  A neutral capture when you just want to record the current state without
  implying it is either the reference or a candidate.

For the very first tuning pass on a machine, you may still use:

- `current-good` if the machine is already in a state you trust
- `snapshot` if you are simply recording the starting point
- `candidate` only after you actually change something

For VM-sensitive tuning:

1. Run host-only first.
2. Then run a second pass with the trading VM active under a normal workload.
3. Prefer the configuration that preserves VM responsiveness while avoiding a
   clear host regression.

## Notes

- The `fio` step writes a temporary 1 GiB file under `/tmp` and removes it on
  exit.
- Do not run multiple benchmark instances at once.
- These benchmarks are for repeatable local comparison, not public ranking.
