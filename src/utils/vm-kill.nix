{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "vm-kill";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils

    procps
    util-linux
  ];

  src = builtins.path { path = ./.; name = "vm-kill"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out
    ls -al $out/

    install \
    -m0755 \
    $out/vm-kill.sh \
    -D \
    $out/bin/vm-kill

    patchShebangs $out/bin/vm-kill

    wrapProgram $out/bin/vm-kill \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
