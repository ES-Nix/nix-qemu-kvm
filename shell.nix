{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    cloud-utils
    nixpkgs-fmt
    openssh
    qemu
    wget
  ];

  shellHook = ''
    echo 'Hello, you are in the nix shell!'
  '';
}