{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "run-vm-kvm";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils

            (import ./runVM.nix { inherit pkgs;})
          ]
          ;

          src = builtins.path { path = ./.; name = "run-vm-kvm"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            install \
            -m0755 \
            $out/run-vm-kvm.sh \
            -D \
            $out/bin/run-vm-kvm

            patchShebangs $out/bin/run-vm-kvm

            wrapProgram $out/bin/run-vm-kvm \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
