{
  description = "Curtis's NixOS Installation Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    with inputs; {
      homeManagerModules.default = import
        ./modules/home-manager/default.nix;
      homeManagerModules.mpNix = import
        ./hosts/mpNix/xresources.nix;
      nixosConfigurations = {

        mpNix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/mpNix/mpNix.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [
                self.homeManagerModules.default
                self.homeManagerModules.mpNix
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
            }
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        iNix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/iNix/iNix.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [
                self.homeManagerModules.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
            }
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        tNix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/tNix/tNix.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [
                self.homeManagerModules.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
            }
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        xiso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/xiso/xiso.nix ];
        };
      };
    };
}
