{
  description = "A flake that has a minimal shell that is able to run cloud images";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgsAllowUnfree = import nixpkgs {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };

        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.qemu = import ./qemu.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        defaultPackage = self.packages.${system}.qemu.vm;

        devShell = import ./shell.nix { inherit pkgs; };
      }
    );
}
