{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "reset-to-backup";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils
          ];

          src = builtins.path { path = ./.; name = "reset-to-backup"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            install \
            -m0755 \
            $out/reset-to-backup.sh \
            -D \
            $out/bin/reset-to-backup

            patchShebangs $out/bin/reset-to-backup

            wrapProgram $out/bin/reset-to-backup \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
