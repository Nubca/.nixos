{ config, pkgs, ... }:

{
  # 1. Core Virtualization Services
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true; # Required for Windows 11
    };
  };

  # 2. Kernel & Low-Latency Optimizations
  # Note: If using AMD, change "intel_iommu=on" to "amd_iommu=on"
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "hugepagesz=2M"
    "hugepages=4096"   # Reserves 8GB RAM for the VM
    "transparent_hugepage=never"
  ];

  # Set CPU to performance mode for consistent order execution speed
  powerManagement.cpuFreqGovernor = "performance";

  # 3. Looking Glass Shared Memory Device
  # Created at /dev/shm/looking-glass with permissions for your user
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 ca libvirtd -"
  ];

  # 4. User Permissions
  users.users.ca.extraGroups = [ "libvirtd" "kvm" "input" "render" "video" ];

  # 5. Required System Packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    looking-glass-client
    spice-gtk
    win-virtio # Windows drivers for high-speed Disk/NIC
  ];
}
