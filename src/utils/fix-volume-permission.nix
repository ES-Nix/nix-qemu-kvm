{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "fix-volume-permission";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils

            find
          ];

          src = builtins.path { path = ./.; name = "fix-volume-permission"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            install \
            -m0755 \
            $out/fix-volume-permission.sh \
            -D \
            $out/bin/fix-volume-permission

            patchShebangs $out/bin/fix-volume-permission

            wrapProgram $out/bin/fix-volume-permission \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
