{
  description = "Home Manager configuration of the current user";
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.

    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, plasma-manager, flake-utils, ... }:
    let userConig = (import ./config.nix { }); in with userConig;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        lib = pkgs.lib;
        shortcutGenerator = import ./shortcut.nix;
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          ./plasma.nix
          (plasma-manager.homeManagerModules.plasma-manager {
            home = {
              username = userConig.username;
              homeDirectory = userConig.homeDirectory;
              stateVersion = "23.05";
            };
          })
        ];
        baseConfig = modules: home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          inherit modules;
        };
        shortcutModule = { ... }: shortcutGenerator {
          inherit lib;
          homeManagerConfiguration = baseConfig modules;
        };
      in
      {
        packages.homeConfigurations."${username}" = baseConfig (modules ++ [ shortcutModule ]);
      } // {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      }
    );
}
