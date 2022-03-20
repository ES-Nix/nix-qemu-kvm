{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "runVM-with-volume";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
    qemu
  ];

  src = builtins.path { path = ./.; name = "runVM-with-volume"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    install \
    -m0755 \
    $out/runVM-with-volume.sh \
    -D \
    $out/bin/runVM-with-volume

    patchShebangs $out/bin/runVM-with-volume

    wrapProgram $out/bin/runVM-with-volume \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
