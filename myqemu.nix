{ pkgs ?  import <nixpkgs> {} }:

pkgs.dockerTools.buildLayeredImage {
  name = "nix-dockertools-multiple-packages";
  tag = "0.0.1";
  contents = with pkgs; [ hello figlet ];

  config.Entrypoint = [ "${pkgs.bashInteractive}/bin/bash" ];

}
