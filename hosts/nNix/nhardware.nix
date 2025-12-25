{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
  # Set kernel parameters for hibernation
    kernelParams = [
      "resume=/dev/disk/by-uuid/af942b97-9d3f-44cb-888b-f74630cc601b"
      "resume_offset=34816"
      "nvidia-drm.modeset=1"
    ];
    kernelModules = [
      "kvm-intel"
    ];
    extraModulePackages = [
    ];
    resumeDevice = lib.mkForce "/dev/disk/by-uuid/af942b97-9d3f-44cb-888b-f74630cc601b";
  };

  swapDevices = [{
    device = "/files1/swapfile";
    size = 36 * 1024; # 36 GB in MB
  }];

  fileSystems = {
    "/" = {
      device = lib.mkForce "/dev/disk/by-uuid/90f78c45-4232-49be-b19a-3b6960d4b88b";
      fsType = "ext4";
    };

    "/boot" = {
      device = lib.mkForce "/dev/disk/by-uuid/4CF1-664A";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/files1" = {
      device = lib.mkForce "/dev/disk/by-uuid/af942b97-9d3f-44cb-888b-f74630cc601b";
      fsType = "ext4";
      options = [ "defaults" "noatime" "nofail" ];
    };

    "/files2" = {
      device = lib.mkForce "/dev/disk/by-uuid/9ee17890-4af6-487c-bec4-05d2a4c04b4a";
      fsType = "ext4";
      options = [ "defaults" "noatime" "nofail" ];
    };
  };

  # Variables
  environment = {
    variables = { # Also see DPI-Hi.nix
      _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"; # Unknown effects
      QT_AUTO_SCREEN_SCALE_FACTOR = "1"; # Unknown effects
    };
    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      NIXOS_OZONE_WL = "1";
    };
  };

  services = {
    fstrim.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable; # Note: Old Patch // {
      #   open = config.boot.kernelPackages.nvidiaPackages.stable.open.overrideAttrs (old: {
      #     patches = (old.patches or [ ]) ++ [
      #       (pkgs.fetchpatch {
      #         name = "get_dev_pagemap.patch";
      #         url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
      #         hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
      #         })
      #       ];
      #     });
      #   };
    };
  };
}
