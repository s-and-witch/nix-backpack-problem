# SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: CC0-1.0

{
  description = "My haskell application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages;

      packageName = "main-package";

      in {
        packages.${packageName} =
          haskellPackages.callCabal2nix packageName ./main-package rec {
            my-dependency = self.packages.${system}.my-dependency;
          };

        packages.my-dependency =
          haskellPackages.callCabal2nix "my-dependency" ./my-dependency rec {
            # Dependency overrides go here
          };

        packages.default = self.packages.${system}.${packageName};
        defaultPackage = self.packages.${system}.default;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ghc
            cabal-install
          ];
        };
        devShell = self.devShells.${system}.default;
      });
}
