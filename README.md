

To run using `nix + flakes`:

First working relevant commit:
`nix develop github:ES-Nix/nix-qemu-kvm/23f67f69d185979829ae8fef9574a23b7f2b7525`


```
nix build github:ES-Nix/nix-qemu-kvm/61c893cc1d0c4a5cf4ae008533f4e454b61c0f48#myqemu.prepare
 ./result/runVM
```

```
nix build .#myqemu.prepare
 ./result/runVM
```
## Credits 

Most of this source is from [zimbatm](https://github.com/zimbatm/nix-experiments/tree/5e4f6941b8f3e90525c4b2acbdd78c766e1f757e/ubuntu-vm).


## Troubloshoting a bug in my setup with poetry2nix

```
echo 'ubuntu' | sudo --stdin sed --in-place '/root    ALL=(ALL:ALL) ALL/a ubuntu    ALL=(ALL:ALL) ALL' /etc/sudoers
curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/f7c5a63df0c998f0c27d4756d2a410b68ea68102/get-nix.sh | sh
. "$HOME"/.nix-profile/etc/profile.d/nix.sh
. ~/.bashrc
flake
nix develop github:ES-Nix/poetry2nix-examples/2087edaaf2fb4f8a5eae4ecfc804cb5f6e026433
```