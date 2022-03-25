{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "ubuntu-qemu-kvm-with-volume-and-nix";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
    qemu

    (import ./vm-kill.nix { inherit pkgs; })
    (import ./backup-current-state.nix { inherit pkgs; })
    (import ./ssh-vm-starts-vm-if-not-running-with-volume.nix { inherit pkgs; })
  ];

  src = builtins.path { path = ./.; name = "ubuntu-qemu-kvm-with-volume-and-nix"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    install \
    -m0755 \
    $out/ubuntu-qemu-kvm-with-volume-and-nix.sh \
    -D \
    $out/bin/ubuntu-qemu-kvm-with-volume-and-nix

    patchShebangs $out/bin/ubuntu-qemu-kvm-with-volume-and-nix

    wrapProgram $out/bin/ubuntu-qemu-kvm-with-volume-and-nix \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
