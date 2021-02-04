

To run using `nix + flakes`:

First working relevant commit:
`nix develop github:ES-Nix/nix-qemu-kvm/23f67f69d185979829ae8fef9574a23b7f2b7525`


`nix build github:ES-Nix/nix-qemu-kvm/61c893cc1d0c4a5cf4ae008533f4e454b61c0f48#myqemu.prepare && ./result/runVM`


`nix build .#myqemu.prepare`

## Credits 

Most of this source is from [zimbatm](https://github.com/zimbatm/nix-experiments/tree/5e4f6941b8f3e90525c4b2acbdd78c766e1f757e/ubuntu-vm).
