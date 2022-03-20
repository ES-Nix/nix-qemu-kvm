{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "backup-current-state";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils

  ];

  src = builtins.path { path = ./.; name = "backup-current-state"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    install \
    -m0755 \
    $out/backup-current-state.sh \
    -D \
    $out/bin/backup-current-state

    patchShebangs $out/bin/backup-current-state

    wrapProgram $out/bin/backup-current-state \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
