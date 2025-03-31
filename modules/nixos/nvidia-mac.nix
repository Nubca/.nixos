{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = lib.mkDefault true;
    facetimehd.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = false;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470; 
    };
  };
  
  boot.kernelParams = [
    "nvidia-drm.modeset=0"
    "nvidia-drm.fbdev=1"
    "vga=normal"
  ];

  services.xserver.videoDrivers = ["nvidia"];
  
  nixpkgs.config = {
    nvidia.acceptLicense = true;
  };
}  
