{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "ubuntu-qemu-kvm";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils
            qemu

          ];

          src = builtins.path { path = ./.; name = "ubuntu-qemu-kvm"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out
            ls -al $out/

            install \
            -m0755 \
            $out/ubuntu-qemu-kvm.sh \
            -D \
            $out/bin/ubuntu-qemu-kvm

            patchShebangs $out/bin/ubuntu-qemu-kvm

            wrapProgram $out/bin/ubuntu-qemu-kvm \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
