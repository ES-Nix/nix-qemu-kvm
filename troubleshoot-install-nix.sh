#!/usr/bin/env bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail




ls /nix/store/ | grep nix-2

# if it has the string 'nix-2', nix is present, and probable that is ease to fix

ls -al /nix/store/iwfs2bfcy7lqwhri94p2i6jc87ih55zk-nix-2.3.10/bin/nix

# More improvement
alias nix='/nix/store/iwfs2bfcy7lqwhri94p2i6jc87ih55zk-nix-2.3.10/bin/nix'

# It works!
nix --version

nix verify

sudo chown -r ubuntu:ubuntu /nix/