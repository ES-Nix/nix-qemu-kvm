{ pkgs ? import <nixpkgs> {} }:
let
  # This is the cloud-init config
  cloudInitWithVolume = {
    ssh_authorized_keys = [
      (builtins.readFile ./vagrant.pub)
    ];
    ssh_pwauth = true;
  };

#    users = {
#        name = "user";
#        passwd = "pwuser";
#        lock_passwd = "false";
#        groups = "usergroup";
#        shell = "${toString "/bin/bash"}";
#        sudo = "${toString "ALL=(ALL) NOPASSWD:ALL"}";
#    };

  image = pkgs.fetchurl {
    url = "https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img";
    hash = "sha256-TdO12IoKeue+KiQ4O1/uv879BadFv5t3hgMmPYE4ax8=";
  };

in
  pkgs.stdenv.mkDerivation rec {
          name = "run-vm-kvm";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils

            qemu
            yj
            (import ./runVM.nix { inherit pkgs;})
          ]
         ++
            (if stdenv.isDarwin then [ ]
            else [ cloud-utils ]);

          src = builtins.path { path = ./.; name = "run-vm-kvm"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out

            cp --reflink=auto "${image}" disk.qcow2
            chmod +w disk.qcow2
            qemu-img resize disk.qcow2 +12G

            mkdir -p $out/bin

            touch $out/userdata
            mv disk.qcow2 $out/disk.qcow2

            {
              echo '#cloud-config'
              echo '${builtins.toJSON cloudInitWithVolume}' | yj -jy
            } > cloud-init.yaml
            cloud-localds userdata.raw cloud-init.yaml
            qemu-img convert -p -f raw userdata.raw -O qcow2 "$out"/userdata.qcow2

            substituteInPlace $out/run-vm-kvm.sh \
              --replace ":-store-disk-name}" ":-$out/disk.qcow2}" \
              --replace ":-store-userdata-name}" ":-$out/userdata.qcow2}"

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
