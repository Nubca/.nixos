# nix-build
{ pkgs ? import <nixpkgs> {}
, nixos ? import <nixpkgs/nixos> {}
}:

let
  packageList = nixos.config.environment.systemPackages;
  concatenator = acc: p: "${acc}, ${p.name}";
in
pkgs.writeTextFile {
  name = "packages";
  text = builtins.foldl' concatenator "" packageList;
}
