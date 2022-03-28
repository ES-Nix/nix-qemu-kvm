#!/usr/bin/env bash



test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix \
&& BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=c0a0dd4976a50fa44c556885f001c803f62a9cfe \
&& NIX_RELEASE_VERSION='nix-2.4pre20210823_af94b54' \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version
&& nix build nixpkgs#hello --no-link
