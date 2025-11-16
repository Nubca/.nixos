{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;
    sessionVariables = {
      ZELLIJ = "";
    };
    bashrcExtra = ''
      if [[ $- == *i* && $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" ]]
      then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
