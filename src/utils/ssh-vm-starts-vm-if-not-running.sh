#!/usr/bin/env bash


# test -d result \
# || nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \

pidof qemu-kvm \
|| (run-vm-kvm < /dev/null &) \
&& ssh-vm
