{ inputs, pkgs, lib, ... }: {
  service.kdeconnnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
}
