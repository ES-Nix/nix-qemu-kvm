#!/usr/bin/env bash



test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix \
&& BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix' \
&& curl -fsSL "${BASE_URL}"'/draft-in-wip/get-nix.sh' | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version \
&& nix build nixpkgs#hello --no-link
