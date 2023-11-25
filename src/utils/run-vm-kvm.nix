{ pkgs ? import <nixpkgs> { } }:
let
  # This is the cloud-init config
  #
  # In the guest VM the file created is:
  # sudo nano /etc/sudoers.d/90-cloud-init-users
  #
  # https://askubuntu.com/a/525681
  # https://askubuntu.com/a/878705

  cloudInit = {
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

  major = "22";
  minor = "04";
  arc = "amd64";

  majorDotMinor = "${major}.${minor}";
  img_orig-22-04 = "ubuntu-${majorDotMinor}-server-cloudimg-${arc}.img";
  ubuntu22-04 = "${majorDotMinor}/release/${img_orig-22-04}";

in
pkgs.stdenv.mkDerivation rec {
  name = "run-vm-kvm";

  image = pkgs.fetchurl {
    url = "https://cloud-images.ubuntu.com/releases/${ubuntu22-04}";
    hash = "sha256-BU2y2IxFS7Ctjf2Ig5VeOUa1fSsL8NAj863jyTzdFOU=";
  };

  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils

    qemu
    yj
    (import ./runVM.nix { inherit pkgs; })
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
    qemu-img resize disk.qcow2 +18G

    mkdir -p $out/bin

    touch $out/userdata
    mv disk.qcow2 $out/disk.qcow2

    {
      echo '#cloud-config'
      echo '${builtins.toJSON cloudInit}' | yj -jy
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
