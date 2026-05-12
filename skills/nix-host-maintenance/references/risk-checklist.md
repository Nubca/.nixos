# Risk Checklist

Treat the following areas as high-impact on `nNix` and call out risk before
proposing changes:

- Boot loader or firmware assumptions
- GPU binding and passthrough device ownership
- VFIO module loading and device IDs
- Initrd contents or initrd kernel modules
- Kernel parameters or CPU power policy defaults
- Display manager and host display path
- Storage layout, mounts, or root-device assumptions

Before changing one of these areas:

1. Confirm the current host problem and avoid speculative churn.
2. Prefer the smallest declarative change that tests the hypothesis.
3. Say whether a reboot is required.
4. Say whether the change can break host boot, graphics, or VM availability.
5. If the goal is VM performance, verify host health first.
