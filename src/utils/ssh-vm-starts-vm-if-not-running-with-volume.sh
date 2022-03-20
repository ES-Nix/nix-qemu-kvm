#!/usr/bin/env bash


# test -d result \
# || nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \

pidof qemu-system-x86_64 \
|| (run-vm-kvm-with-volume < /dev/null &) \
&& ssh-vm
