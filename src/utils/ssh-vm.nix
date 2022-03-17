{ pkgs ? import <nixpkgs> {}, vm-utils }:
pkgs.stdenv.mkDerivation rec {
          name = "ssh-vm";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils

            procps
            util-linux
          ]
          ++
          vm-utils
          ;

          src = builtins.path { path = ./.; name = "ssh-vm"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            install \
            -m0755 \
            $out/ssh-vm.sh \
            -D \
            $out/bin/ssh-vm

            patchShebangs $out/bin/ssh-vm

            wrapProgram $out/bin/ssh-vm \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
