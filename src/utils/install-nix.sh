#!/usr/bin/env bash



test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix \
&& BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=61bc33388f399fd3de71510b5ca20f159c803491 \
&& NIX_RELEASE_VERSION='nix-2.4pre20210823_af94b54' \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version
&& nix build nixpkgs#hello --no-link
