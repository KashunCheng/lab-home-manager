{
  description = "Home Manager configuration of kashun";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, flake-utils, ... }:
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
        modules = [ ./home.nix ];
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
        packages.homeConfigurations."kashun" = baseConfig (modules ++ [ shortcutModule ]);
      } // {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      }
    );
}
