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

        # It should be groupped somehow
        packages.vm-kill = import ./src/utils/vm-kill.nix { inherit pkgs; };

        #

        packages.qemu = import ./qemu.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        defaultPackage = self.packages.${system}.qemu.vm;

        devShell = import ./shell.nix { inherit pkgs; utils = [ packages.vm-kill ]; };

        # vm-kill; reset-to-backup && nix run .#ubuntu-qemu-kvm-dev

        packages.ubuntu-qemu-kvm-dev = import ./src/utils/ubuntu-qemu-kvm-dev.nix { inherit pkgs; };

        packages.ubuntu-qemu-kvm = import ./src/utils/ubuntu-qemu-kvm.nix { inherit pkgs; vm-utils = self.packages.${system}.qemu.vm; };

        apps.ubuntu-qemu-kvm-dev = flake-utils.lib.mkApp {
          name = "ubuntu-qemu-kvm-dev";
          drv = packages.ubuntu-qemu-kvm-dev;
        };

        apps.ubuntu-qemu-kvm = flake-utils.lib.mkApp {
          name = "ubuntu-qemu-kvm";
          drv = packages.ubuntu-qemu-kvm;
        };

      }
    );
}
