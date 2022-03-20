{ pkgs ? import <nixpkgs> {} }:
let

  cloudInitWithVolume = {
    ssh_authorized_keys = [
      (builtins.readFile ./vagrant.pub)
    ];
    ssh_pwauth = true;

    # Source of magic number msize=262144
    # https://askubuntu.com/questions/548208/sharing-folder-with-vm-through-libvirt-9p-permission-denied/1259833#1259833
    mounts = [
      [ "hostshare" "/home/ubuntu/code" "9p" "defaults,trans=virtio,access=any,version=9p2000.L,cache=none,msize=262144,rw" ]
    ];
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
          name = "run-vm-kvm-with-volume";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils # We use pwd binary at run time

            cloud-utils
            yj
            qemu

            (import ./runVM-with-volume.nix { inherit pkgs;})
          ]
          ;

          src = builtins.path { path = ./.; name = "run-vm-kvm-with-volume"; };
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

            substituteInPlace $out/run-vm-kvm-with-volume.sh \
              --replace ":-store-disk-name}" ":-$out/disk.qcow2}" \
              --replace ":-store-userdata-name}" ":-$out/userdata.qcow2}"

            install \
            -m0755 \
            $out/run-vm-kvm-with-volume.sh \
            -D \
            $out/bin/run-vm-kvm-with-volume

            patchShebangs $out/bin/run-vm-kvm-with-volume

            wrapProgram $out/bin/run-vm-kvm-with-volume \
              --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
          '';

        }
