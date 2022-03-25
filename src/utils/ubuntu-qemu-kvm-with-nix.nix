{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "ubuntu-qemu-kvm-with-nix";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils

    (import ./vm-kill.nix { inherit pkgs; })
    (import ./ssh-vm-starts-vm-if-not-running.nix { inherit pkgs; })
  ];

  src = builtins.path { path = ./.; name = "ubuntu-qemu-kvm-with-nix"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    # ls -al $out/

    install \
    -m0755 \
    $out/ubuntu-qemu-kvm-with-nix.sh \
    -D \
    $out/bin/ubuntu-qemu-kvm-with-nix

    patchShebangs $out/bin/ubuntu-qemu-kvm-with-nix

    wrapProgram $out/bin/ubuntu-qemu-kvm-with-nix \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
