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
          ];

          src = builtins.path { path = ./.; name = "ssh-vm"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            ls -al "${vm-utils}/ssh-vm"

            # Hack my self code, sad life...
            substituteInPlace $out/ssh-vm.sh \
            --replace "run-vm-kvm" "${vm-utils}/run-vm-kvm" \
            --replace "ssh-vm" "${vm-utils}/ssh-vm"

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
