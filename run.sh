#!/usr/bin/env bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail



#wget https://termbin.com/9w58 --output-document=user-data

wget https://cloud-images.ubuntu.com/minimal/releases/focal/release-20210130/ubuntu-20.04-minimal-cloudimg-amd64.img

cloud-localds user-data.img user-data

qemu-img create -f qcow2 -o backing_file=ubuntu-20.04-minimal-cloudimg-amd64.img teste.qcow2 8G


qemu-system-x86_64 -enable-kvm -m 4G -vga virtio -drive file=teste.qcow2,if=virtio -nic user,model=virtio-net-pci -drive file=user-data.img,format=raw,if=virtio

#rm --recursive --verbose \
#teste.qcow2 \
#ubuntu-20.04-minimal-cloudimg-amd64.img \
#user-data \
#user-data.img