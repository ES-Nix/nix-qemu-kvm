{ pkgs ? import <nixpkgs> {}, vm-utils }:
pkgs.stdenv.mkDerivation rec {
          name = "vm-clear-all-qcow2-and-img";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils

          ]
          ++
          vm-utils
          ;

          src = builtins.path { path = ./.; name = "vm-clear-all-qcow2-and-img"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            install \
            -m0755 \
            $out/vm-clear-all-qcow2-and-img.sh \
            -D \
            $out/bin/vm-clear-all-qcow2-and-img

            patchShebangs $out/bin/vm-clear-all-qcow2-and-img

            wrapProgram $out/bin/vm-clear-all-qcow2-and-img \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
