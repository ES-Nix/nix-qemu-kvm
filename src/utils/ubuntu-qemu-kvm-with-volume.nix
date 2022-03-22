{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "ubuntu-qemu-kvm-with-volume";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
    qemu

    (import ./vm-kill.nix { inherit pkgs; })
    (import ./run-vm-kvm-with-volume.nix { inherit pkgs; })
    (import ./backup-current-state.nix { inherit pkgs; })
    (import ./ssh-vm-starts-vm-if-not-running-with-volume.nix { inherit pkgs; })
  ];

  src = builtins.path { path = ./.; name = "ubuntu-qemu-kvm-with-volume"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    install \
    -m0755 \
    $out/ubuntu-qemu-kvm-with-volume.sh \
    -D \
    $out/bin/ubuntu-qemu-kvm-with-volume

    patchShebangs $out/bin/ubuntu-qemu-kvm-with-volume

    wrapProgram $out/bin/ubuntu-qemu-kvm-with-volume \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
