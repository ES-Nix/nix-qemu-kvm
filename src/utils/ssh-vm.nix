{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "ssh-vm";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils

    openssh
  ];

  src = builtins.path { path = ./.; name = "ssh-vm"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    substituteInPlace $out/ssh-vm.sh \
    --replace "./vagrant" "${src}/vagrant"

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
