#!/usr/bin/env bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail


# From:
# https://github.com/zimbatm/nix-experiments/commit/47e9d8987c938e1d4e0762963edb7ec04ca6cfb8#diff-57e32faa6f3b010168f5acb19a9946f7f6af0845ea814c67ce33834f035287fe
if [ ! -f ubuntu-18.04-server-cloudimg-amd64.img ]; then
    echo "Not found the file ubuntu-18.04-server-cloudimg-amd64.img! Downloading it!"
    wget https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img --output-document=ubuntu-18.04-server-cloudimg-amd64.img
fi

if [ ! -f user-data18.04 ]; then
  echo "Not found the file user-data18.04.img! Creating it!"
  cloud-localds user-data18.04.img user-data18.04
fi

if [ ! -f teste18.04.qcow2 ]; then
    echo "Not found the file teste18.04.qcow2! Creating it!"
    qemu-img create -f qcow2 -o backing_file=ubuntu-18.04-server-cloudimg-amd64.img teste18.04.qcow2 8G
fi


qemu-system-x86_64 -enable-kvm -m 4G -vga virtio -drive file=teste18.04.qcow2,if=virtio -nic user,model=virtio-net-pci -drive file=user-data18.04.img,format=raw,if=virtio
