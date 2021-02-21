

To run using `nix + flakes`:

First working relevant commit:
`nix develop github:ES-Nix/nix-qemu-kvm/23f67f69d185979829ae8fef9574a23b7f2b7525`


```
nix build github:ES-Nix/nix-qemu-kvm/f991d5a3125df5524f92600e778ae3581f2a26b7#myqemu.prepare
./result/runVM
```

```
nix build .#myqemu.prepare
./result/runVM
```
## Credits 

Most of this source is from [zimbatm](https://github.com/zimbatm/nix-experiments/tree/5e4f6941b8f3e90525c4b2acbdd78c766e1f757e/ubuntu-vm).


## Good links

- [Cloud config examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)
- [Empty password field in /etc/passwd](https://security.stackexchange.com/questions/194425/empty-password-field-in-etc-passwd), 
"An `*` or `!` means the account don't have a password and no password will access the account." [source](https://security.stackexchange.com/a/194429)
[What's all those users in the /etc/passwd file?](https://superuser.com/a/750395)
- [Understanding /etc/passwd File Format](https://www.cyberciti.biz/faq/understanding-etcpasswd-file-format/)
- [Understanding /etc/shadow file](https://www.cyberciti.biz/faq/understanding-etcshadow-file/)
- [How do I set a custom password with Cloud-init on Ubuntu 20.04?](https://stackoverflow.com/a/61868231)
- [Password in cloud-init doesn’t seem to work, default one does though (for ubuntu)](https://discuss.linuxcontainers.org/t/password-in-cloud-init-doesnt-seem-to-work-default-one-does-though-for-ubuntu/9401/8)
- [local-hostname: instance-1](https://medium.com/@art.vasilyev/use-ubuntu-cloud-image-with-kvm-1f28c19f82f8)
- TODO: understant if it pays off [use raw instead of qcow2](https://www.reddit.com/r/NixOS/comments/iorlow/nixos_setup_libvirtdqemukvmvirtmanager_why_is_the/g4gos4k/?utm_source=reddit&utm_medium=web2x&context=3)


## Troubloshoting a bug in my setup with poetry2nix

```
echo 'b' | sudo --stdin sed --in-place '/root    ALL=(ALL:ALL) ALL/a ubuntu    ALL=(ALL:ALL) ALL' /etc/sudoers
curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/3c9d46f016ad1f1384791a1900cb5678cf7deb8a/get-nix.sh | sh
. "$HOME"/.nix-profile/etc/profile.d/nix.sh
. ~/.profile
flake
nix develop github:ES-Nix/poetry2nix-examples/2087edaaf2fb4f8a5eae4ecfc804cb5f6e026433
```
