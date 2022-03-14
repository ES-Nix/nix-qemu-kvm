{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "ubuntu-qemu-kvm-dev";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils
            qemu

          ];

          src = builtins.path { path = ./.; name = "ubuntu-qemu-kvm-dev"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out
            ls -al $out/

            install \
            -m0755 \
            $out/ubuntu-qemu-kvm-dev.sh \
            -D \
            $out/bin/ubuntu-qemu-kvm-dev

            patchShebangs $out/bin/ubuntu-qemu-kvm-dev

            wrapProgram $out/bin/ubuntu-qemu-kvm-dev \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }