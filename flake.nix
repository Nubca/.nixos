{
  description = "Curtis's NixOS Installation Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/91bf6dffa21c7709607c9fdbf9a6acb44e7a0a5d";
    # nixpkgs.url = "github:Nubca/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-flake = {
      url = "github:Nubca/nvim-flake/working";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ns-flake = {
      url = "github:gvolpe/niri-scratchpad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
       };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: with inputs; {
    homeManagerModules = {
      default = import ./modules/home-manager/default.nix;
      HiDPI = import ./modules/home-manager/DPI-Hi.nix;
      NormDPI = import ./modules/home-manager/DPI-Low.nix;
    };
    nixosConfigurations = {
      nNix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          disks = [ "/dev/nvme0n1" "/dev/sdb" "/dev/sdc" ];
          encryptRaid = true;
          };
        modules = [
          ./hosts/nNix/nNix.nix
          home-manager.nixosModules.home-manager
	        # inputs.disko.nixosModules.disko
          inputs.niri-flake.nixosModules.niri
          {
            home-manager = {
              sharedModules = [
                self.homeManagerModules.default
                # self.homeManagerModules.HiDPI
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      pNix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          };
        modules = [
          ./hosts/pNix/pNix.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              sharedModules = [
                self.homeManagerModules.default
                # self.homeManagerModules.HiDPI
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      mpNix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          };
        modules = [
          ./hosts/mpNix/mpNix.nix
	        inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              sharedModules = [
                self.homeManagerModules.default
                self.homeManagerModules.HiDPI
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      iNix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          };
        modules = [
          ./hosts/iNix/iNix.nix
	        inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              sharedModules = [
                self.homeManagerModules.default
                self.homeManagerModules.NormDPI
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      uMix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          };
        modules = [
          ./hosts/uMix/uMix.nix
	        inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              sharedModules = [
                self.homeManagerModules.default
                self.homeManagerModules.NormDPI
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      tNix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          };
        modules = [
          ./hosts/tNix/tNix.nix
	        inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              sharedModules = [
                self.homeManagerModules.default
                self.homeManagerModules.NormDPI
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      xIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          };
        modules = [
          ./iso_flake/xIso.nix
        ];
      };
    };
  };
}
