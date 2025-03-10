{ inputs, pkgs, lib, ... }: {
  services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
  home.packages = [ pkgs.localsend ];
}
