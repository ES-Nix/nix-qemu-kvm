{
  description = "A flake that has a minimal shell that is able to run cloud images";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgsAllowUnfree = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.qemu = import ./qemu.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        defaultPackage = self.packages.${system}.qemu.vm;

        devShell = import ./shell.nix { inherit pkgs; };

        # vm-kill; reset-to-backup && nix run .#ubuntu-qemu-kvm-dev

        packages.ubuntu-qemu-kvm-dev = import ./ubuntu-qemu-kvm-dev.nix { inherit pkgs; };

        apps.ubuntu-qemu-kvm-dev = flake-utils.lib.mkApp {
          name = "ubuntu-qemu-kvm-dev";
          drv = packages.ubuntu-qemu-kvm-dev;
        };

      }
    );
}
