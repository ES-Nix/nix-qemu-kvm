{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "refresh";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
  ];

  src = builtins.path { path = ./.; name = "refresh"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out
    # ls -al $out/

    install \
    -m0755 \
    $out/refresh.sh \
    -D \
    $out/bin/refresh

    patchShebangs $out/bin/refresh

    wrapProgram $out/bin/refresh \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
