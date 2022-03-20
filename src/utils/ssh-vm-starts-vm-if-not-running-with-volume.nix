{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "ssh-vm-starts-vm-if-not-running-with-volume";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils

            qemu

            (import ./ssh-vm.nix { inherit pkgs; })
            (import ./run-vm-kvm-with-volume.nix { inherit pkgs; })
          ];

          src = builtins.path { path = ./.; name = "ssh-vm-starts-vm-if-not-running-with-volume"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            install \
            -m0755 \
            $out/ssh-vm-starts-vm-if-not-running-with-volume.sh \
            -D \
            $out/bin/ssh-vm-starts-vm-if-not-running-with-volume

            patchShebangs $out/bin/ssh-vm-starts-vm-if-not-running-with-volume

            wrapProgram $out/bin/ssh-vm-starts-vm-if-not-running-with-volume \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"

          '';

        }
