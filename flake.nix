{
  description = "A flake that has a minimal shell that is able to run cloud images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = allAttrs@{ self, nixpkgs, flake-utils, ...}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgsAllowUnfree = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        pkgs = nixpkgs.legacyPackages.${system};

          # https://gist.github.com/tpwrules/34db43e0e2e9d0b72d30534ad2cda66d#file-flake-nix-L28
          pleaseKeepMyInputs = pkgsAllowUnfree.writeTextDir "bin/.please-keep-my-inputs"
            (builtins.concatStringsSep " " (builtins.attrValues allAttrs));
      in
      rec {

          formatter = pkgsAllowUnfree.nixpkgs-fmt;

        # It should be groupped somehow
        packages.vm-kill = import ./src/utils/vm-kill.nix { inherit pkgs; };
        packages.ssh-vm-starts-vm-if-not-running = import ./src/utils/ssh-vm-starts-vm-if-not-running.nix { inherit pkgs; };
        packages.ssh-vm-starts-vm-if-not-running-with-volume = import ./src/utils/ssh-vm-starts-vm-if-not-running-with-volume.nix { inherit pkgs; };
        packages.ssh-vm = import ./src/utils/ssh-vm.nix { inherit pkgs; };
        packages.backup-current-state = import ./src/utils/backup-current-state.nix { inherit pkgs; };
        packages.refresh = import ./src/utils/refresh.nix { inherit pkgs; };
        packages.reset-to-backup = import ./src/utils/reset-to-backup.nix { inherit pkgs; };
        packages.vm-clear-all-qcow2-and-img = import ./src/utils/vm-clear-all-qcow2-and-img.nix { inherit pkgs; };

        packages.runVM = import ./src/utils/runVM.nix { inherit pkgs; };
        packages.run-vm-kvm = import ./src/utils/run-vm-kvm.nix { inherit pkgs; };
        packages.run-vm-kvm-with-volume = import ./src/utils/run-vm-kvm-with-volume.nix { inherit pkgs; };

        packages.fix-volume-permission = import ./src/utils/fix-volume-permission.nix { inherit pkgs; };
        packages.install-nix = import ./src/utils/install-nix.nix { inherit pkgs; };
        #

        # packages.qemu = import ./qemu.nix {
        #  pkgs = nixpkgs.legacyPackages.${system};
        # };
        #
        # packages.vm-refactor = import ./src/utils/vm-refactor.nix {
        #  pkgs = nixpkgs.legacyPackages.${system};
        #  # runVM = self.packages.${system}.runVM;
        #  # run-vm-kvm = self.packages.${system}.run-vm-kvm;
        # };

        defaultPackage = self.packages.${system}.ubuntu-qemu-kvm;

        packages.ubuntu-qemu-kvm = import ./src/utils/ubuntu-qemu-kvm.nix { inherit pkgs; };
        packages.ubuntu-qemu-kvm-with-nix = import ./src/utils/ubuntu-qemu-kvm-with-nix.nix { inherit pkgs; };

        packages.ubuntu-qemu-kvm-dev = import ./src/utils/ubuntu-qemu-kvm-dev.nix { inherit pkgs; };

        packages.ubuntu-qemu-kvm-with-volume = import ./src/utils/ubuntu-qemu-kvm-with-volume.nix {
          inherit pkgs;
        };

        packages.ubuntu-qemu-kvm-with-volume-and-nix = import ./src/utils/ubuntu-qemu-kvm-with-volume-and-nix.nix {
          inherit pkgs;
        };

        # `nix develop`
        devShells.default = pkgs.mkShell {

          buildInputs = with pkgs; [
            self.packages.${system}.vm-kill
            self.packages.${system}.ssh-vm
            self.packages.${system}.backup-current-state
            self.packages.${system}.refresh
            self.packages.${system}.reset-to-backup
            self.packages.${system}.vm-clear-all-qcow2-and-img

            self.packages.${system}.run-vm-kvm
            self.packages.${system}.run-vm-kvm-with-volume

            self.packages.${system}.ssh-vm-starts-vm-if-not-running
            self.packages.${system}.ssh-vm-starts-vm-if-not-running-with-volume

            self.packages.${system}.ubuntu-qemu-kvm
            self.packages.${system}.ubuntu-qemu-kvm-with-nix
            self.packages.${system}.ubuntu-qemu-kvm-with-volume
            self.packages.${system}.ubuntu-qemu-kvm-with-volume-and-nix

            # self.packages.${system}.qemu.vm

            nixpkgs-fmt
            # shellcheck # ghc-8.10.6
            findutils
            pleaseKeepMyInputs
          ];

          shellHook = ''
            # TODO: document this
            export TMPDIR=/tmp

            # find . -type f -iname '*.nix' -exec nixpkgs-fmt {} \;

              test -d .profiles || mkdir -v .profiles

              test -L .profiles/dev \
              || nix develop .# --profile .profiles/dev --command true

              test -L .profiles/dev-shell-default \
              || nix build $(nix eval --impure --raw .#devShells."$system".default.drvPath) --out-link .profiles/dev-shell-"$system"-default
          '';
        };

        defaultApp = apps.ubuntu-qemu-kvm;
        apps.ubuntu-qemu-kvm = flake-utils.lib.mkApp {
          name = "ubuntu-qemu-kvm";
          drv = packages.ubuntu-qemu-kvm;
        };

        apps.ubuntu-qemu-kvm-dev = flake-utils.lib.mkApp {
          name = "ubuntu-qemu-kvm-dev";
          drv = packages.ubuntu-qemu-kvm-dev;
        };

        apps.ubuntu-qemu-kvm-with-volume = flake-utils.lib.mkApp {
          name = "ubuntu-qemu-kvm-with-volume";
          drv = packages.ubuntu-qemu-kvm-with-volume;
        };

        # apps.vm-refactor = flake-utils.lib.mkApp {
        #  name = "vm-refactor";
        #  drv = packages.vm-refactor;
        # };

        apps.runVM = flake-utils.lib.mkApp {
          name = "runVM";
          drv = packages.runVM;
        };

        apps.ssh-vm-starts-vm-if-not-running = flake-utils.lib.mkApp {
          name = "ssh-vm-starts-vm-if-not-running";
          drv = packages.ssh-vm-starts-vm-if-not-running;
        };

        apps.ssh-vm = flake-utils.lib.mkApp {
          name = "ssh-vm";
          drv = packages.ssh-vm;
        };

        apps.fix-volume-permission = flake-utils.lib.mkApp {
          name = "fix-volume-permission";
          drv = packages.fix-volume-permission;
        };

        checks = {
          nixpkgsFmt = pkgs.runCommand "check-nix-format" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            mkdir $out #success
          '';
          # find . -type f -iname '*.nix' -exec nixpkgs-fmt {} \;

        } // packages;
      }


    );
}
