

To run using `nix + flakes`:

First working relevant commit:
`nix develop github:ES-Nix/nix-qemu-kvm/23f67f69d185979829ae8fef9574a23b7f2b7525`


```
nix build github:ES-Nix/nix-qemu-kvm/51c7b855f579d806969bef8d93b3ff96830ff294#qemu.prepare
./result/runVM
```

## Intalling via git
```
git clone https://github.com/ES-Nix/nix-qemu-kvm.git \
&& cd nix-qemu-kvm \
&& git checkout c16c4bed78398af43cd3d3f0f1ddb4491df5f479 \
&& nix build .#qemu.prepare \
&& ./result/runVM
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


# KVM


### Install Docker


```bash
curl -fsSL https://get.docker.com | sudo sh \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& sudo reboot
```

TODO: make an conditional in this:
```bash
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=f59ad3bd8acd1494856019878476b41f2c307c59 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& cd "$TMPDIR" \
&& echo "$(readlink -f $(which nix-env))" > old_nix_path \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix-env --uninstall $(cat old_nix_path) && nix profile install nixpkgs#nixFlakes' \
&& rm -rfv old_nix_path \
&& cd ~ \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version

sudo groupadd kvm
sudo usermod --append --groups kvm $(stat -c "%U" $(tty))
sudo chown -R $(id -u):$(id -g) /dev/kvm /dev/pts /dev/ptmx
groups

sudo su -c 'echo 3 > /proc/sys/vm/drop_caches'

curl -fsSL https://get.docker.com | sudo sh \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& sudo reboot

```

> "L0" – the bare metal host, running KVM
> "L1" – a VM running on L0; also called the "guest hypervisor" — as it itself is capable of running KVM
> "L2" – a VM running on L1, also called the "nested guest"
> From: https://www.linux-kvm.org/page/Nested_Guests



```bash
stat /dev/kvm
groups | rg 'kvm'
cat /sys/module/kvm_intel/parameters/nested | rg 'Y'
modinfo kvm_intel | rg -i nested
egrep --color -i "svm|vmx" /proc/cpuinfo]
grep -o 'vmx\|svm' /proc/cpuinfo
```
Adapted from: https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/ e https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/

In NixOS
```
boot.kernelModules = [ "kvm-intel" ];
boot.extraModprobeConfig = "options kvm_intel nested=1";
```
https://github.com/NixOS/nixpkgs/issues/27930#issuecomment-417943781

About `libvirt`: https://nixos.wiki/wiki/Libvirt

--mount source="$NIX_CACHE_VOLUME",target=/nix \
--mount source="$NIX_CACHE_VOLUME",target=/home/pedroregispoar/.cache/ \
--mount source="$NIX_CACHE_VOLUME",target=/home/pedroregispoar/.config/nix/ \
--mount source="$NIX_CACHE_VOLUME",target=/home/pedroregispoar/.nix-defexpr/ \

NIX_CACHE_VOLUME='nix-cache-volume'

# Burn cache, as it may make you waste a lot of time!
docker ps --all --quiet | xargs --no-run-if-empty docker stop --time=0 \
&& docker ps --all --quiet | xargs --no-run-if-empty docker rm --force \
&& docker volume rm --force "$NIX_CACHE_VOLUME"


docker \
run \
--cap-add=ALL \
--device=/dev/kvm \
--interactive=true \
--mount source="$NIX_CACHE_VOLUME",target=/nix \
--privileged=true \
--tty=false \
--rm=true \
--workdir='/code' \
--volume "$(pwd)":'/code' \
--volume '/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare
timeout 60 result/runVM
COMMANDS


docker \
run \
--cap-add ALL \
--device=/dev/kvm \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
--volume '/proc/':'/proc':rw \
docker.nix-community.org/nixpkgs/nix-flakes


docker \
run \
--cap-add=ALL \
--device=/dev/kvm \
--interactive=true \
--mount source="$NIX_CACHE_VOLUME",target=/nix \
--privileged=true \
--tty=true \
--rm=true \
--workdir='/code' \
--volume "$(pwd)":'/code' \
--volume '/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes
