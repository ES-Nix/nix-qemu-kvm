

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
```


It is not totaly working:
```bash
sudo groupadd kvm
sudo usermod --append --groups kvm "$USER"
sudo chown -R "$USER":kvm /dev/kvm /dev/pts /dev/ptmx
```

```bash
ubuntu@ubuntu:~$ stat /dev/kvm /dev/pts /dev/ptmx
  File: /dev/kvm
  Size: 0               Blocks: 0          IO Block: 4096   character special file
Device: 6h/6d   Inode: 346         Links: 1     Device type: a,e8
Access: (0600/crw-------)  Uid: ( 1000/  ubuntu)   Gid: ( 1001/     kvm)
Access: 2021-06-26 20:14:26.260000000 +0000
Modify: 2021-06-26 20:14:26.260000000 +0000
Change: 2021-06-26 20:15:24.287113618 +0000
 Birth: -
  File: /dev/pts
  Size: 0               Blocks: 0          IO Block: 1024   directory
Device: 15h/21d Inode: 1           Links: 2
Access: (0755/drwxr-xr-x)  Uid: ( 1000/  ubuntu)   Gid: ( 1001/     kvm)
Access: 2021-06-26 20:15:24.287113618 +0000
Modify: 2021-06-26 20:14:20.672000000 +0000
Change: 2021-06-26 20:15:24.287113618 +0000
 Birth: -
  File: /dev/ptmx
  Size: 0               Blocks: 0          IO Block: 4096   character special file
Device: 6h/6d   Inode: 86          Links: 1     Device type: 5,2
Access: (0666/crw-rw-rw-)  Uid: ( 1000/  ubuntu)   Gid: ( 1001/     kvm)
Access: 2021-06-26 20:14:25.900000000 +0000
Modify: 2021-06-26 20:14:25.900000000 +0000
Change: 2021-06-26 20:15:24.287113618 +0000
 Birth: -
```

After `sudo reboot` it does not keep the permisions:

```bash
ubuntu@ubuntu:~$ stat /dev/kvm /dev/pts /dev/ptmx
  File: /dev/kvm
  Size: 0               Blocks: 0          IO Block: 4096   character special file
Device: 6h/6d   Inode: 346         Links: 1     Device type: a,e8
Access: (0600/crw-------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-06-26 20:14:26.260000000 +0000
Modify: 2021-06-26 20:14:26.260000000 +0000
Change: 2021-06-26 20:14:26.260000000 +0000
 Birth: -
  File: /dev/pts
  Size: 0               Blocks: 0          IO Block: 1024   directory
Device: 15h/21d Inode: 1           Links: 2
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-06-26 20:14:20.672000000 +0000
Modify: 2021-06-26 20:14:20.672000000 +0000
Change: 2021-06-26 20:14:20.672000000 +0000
 Birth: -
  File: /dev/ptmx
  Size: 0               Blocks: 0          IO Block: 4096   character special file
Device: 6h/6d   Inode: 86          Links: 1     Device type: 5,2
Access: (0666/crw-rw-rw-)  Uid: (    0/    root)   Gid: (    5/     tty)
Access: 2021-06-26 20:14:25.900000000 +0000
Modify: 2021-06-26 20:14:25.900000000 +0000
Change: 2021-06-26 20:14:25.900000000 +0000
 Birth: -
```

Why??!

```bash
curl -fsSL https://get.docker.com | sudo sh \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& sudo reboot
```


### Hard tests:

```bash
sudo chown -R ubuntu:kvm /dev/kvm /dev/pts /dev/ptmx
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare-l
nix shell nixpkgs#coreutils --command timeout 60 result/runVML result/runVML
nix store gc
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare
nix store gc
nix build github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso
nix store gc
nix \
build \
github:ES-Nix/nixosTest/2f37db3fe507e725f5e94b42a942cdfef30e5d75#checks.x86_64-linux.test-nixos
```


```bash
result/clean_all && nix build github:ES-Nix/nix-qemu-kvm/22f79c3d114c2b36955989f6742b3430b6d9e9aa#qemu.prepare
result/clean_all && nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare
nix log /nix/store/*-prepare.drv
```


```bash
nix profile install nixpkgs#ripgrep
cat /etc/group
sudo groupadd kvm 
sudo chown -R :kvm /dev/kvm
sudo usermod --append --groups kvm "$USER"
cat /etc/group
sudo chmod o+x /dev/kvm
groups
```



> "L0" – the bare metal host, running KVM
> "L1" – a VM running on L0; also called the "guest hypervisor" — as it itself is capable of running KVM
> "L2" – a VM running on L1, also called the "nested guest"
> From: https://www.linux-kvm.org/page/Nested_Guests


```bash
nix profile install nixpkgs#ripgrep
groups | rg 'kvm' || echo 'Error'
cat /sys/module/kvm_intel/parameters/nested | rg 'Y' || echo 'Error'
modinfo kvm_intel | rg -i nested || echo 'Error'
egrep --color -i "svm|vmx" /proc/cpuinfo || echo 'Error'
grep -o 'vmx\|svm' /proc/cpuinfo || echo 'Error'
stat --format=%G /dev/kvm | rg 'kvm' || echo 'Error'
grep -o 'vmx\|svm' /proc/cpuinfo | wc --lines | rg 8 || echo 'Error'
grep "^Mem" /proc/meminfo || echo 'Error'
```
Adapted from: https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/ e https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/
grep -o 'vmx\|svm' /proc/cpuinfo


```bash
sudo su -c "echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf"
```

Commands to test:
```bash
cat /etc/modprobe.d/kvm.conf | grep kvm_
cat /sys/module/kvm_intel/parameters/nested
grep -o 'vmx\|svm' /proc/cpuinfo
grep -o 'vmx\|svm' /proc/cpuinfo | wc --lines | rg 8
grep "^Mem" /proc/meminfo
free -m
```

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

```bash
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
echo begined
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare
echo 1
timeout 60 result/runVM
echo 2
COMMANDS
```

docker \
run \
--cap-add=SYS_ADMIN \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--tty=false \
--rm=true \
--volume='/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
nix build github:ES-Nix/nix-qemu-kvm/22f79c3d114c2b36955989f6742b3430b6d9e9aa#qemu.prepare
echo $?
nix shell nixpkgs#coreutils --command timeout 60 result/runVM
nix \
build \
github:ES-Nix/nixosTest/2f37db3fe507e725f5e94b42a942cdfef30e5d75#checks.x86_64-linux.test-nixos
COMMANDS


docker \
run \
--cap-add=SYS_ADMIN \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--tty=false \
--rm=true \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=0755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
echo 'The test with: nix-qemu-kvm started'
nix build github:ES-Nix/nix-qemu-kvm/22f79c3d114c2b36955989f6742b3430b6d9e9aa#qemu.prepare
echo $?
nix shell nixpkgs#coreutils --command timeout 60 result/runVM
nix store gc
echo 'The test with: test-nixos started'
nix \
build \
github:ES-Nix/nixosTest/2f37db3fe507e725f5e94b42a942cdfef30e5d75#checks.x86_64-linux.test-nixos
echo 'The test with: nixosConfigurations.pedroregispoar started'
nix store gc
nix \
build \
github:PedroRegisPOAR/NixOS-configuration.nix#nixosConfigurations.pedroregispoar.config.system.build.toplevel
COMMANDS


```bash
docker \
run \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
docker.nix-community.org/nixpkgs/nix-flakes

mkdir --parent --mode=0755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
nix shell nixpkgs#shadow nixpkgs#su nixpkgs#neovim

groupadd nixgroup
groupadd kvm
useradd -s /bin/bash --uid 56789 nixuser

usermod --append nixuser kvm
```


```bash
docker \
run \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--tty=false \
--rm=true \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
nix profile install nixpkgs#hello
echo $?
hello
COMMANDS
```

--cap-add SYS_ADMIN \
--cpus='0.5' \
--device=/dev/kvm \


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


docker \
run \
--cap-add=ALL \
--device=/dev/kvm \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
docker.nix-community.org/nixpkgs/nix-flakes


Did not work: https://releases.nixos.org/nix-dev/2015-December/019018.html


https://stackoverflow.com/questions/46464785/cannot-allocate-memory-despite-free-reporting-available
https://serverfault.com/a/982161
https://serverfault.com/a/807965
https://unix.stackexchange.com/a/34100


> Perhaps KVM doesn’t implement the speed step control registers, so it
> cannot pass it through. (Note that you typically don’t want to let a 
> guest access the hardware control registers directly, because then it 
> can affect other guests.)
https://stackoverflow.com/questions/57440881/qemu-kvm-missing-cpu-feature-flags-kvm-not-pasing-through#comment101365485_57440881

`wsl -u root`
https://superuser.com/a/1632124


nix build .#qemu.prepare \
&& result/refresh && result/runVM

nix build .#qemu.scripts \
&& result/backupCurrentState zsh-nix-flake \
&& result/resetToBackup zsh-nix-flake \
&& nix build .#qemu.prepare \
&& result/runVM


nix build .#qemu.scripts \
&& result/resetToBackup zsh-nix-flake \
&& nix build .#qemu.prepare \
&& result/runVM


[Terraform and KVM (x86) ](https://titosoft.github.io/kvm/terraform-and-kvm/)

[Using the Libvirt Provisioner With Terraform for KVM](https://blog.ruanbekker.com/blog/2020/10/08/using-the-libvirt-provisioner-with-terraform-for-kvm/)

[Installing and launching an ARM VM from Proxmox GUI](https://www.reddit.com/r/arm/comments/ed71cq/installing_and_launching_an_arm_vm_from_proxmox/)

[Proxmox vs ESXi: 9 Compelling reasons why my choice was clear](https://www.smarthomebeginner.com/proxmox-vs-esxi/)

[Any experience with NixOS as hypervisor?](https://discourse.nixos.org/t/any-experience-with-nixos-as-hypervisor/11215)

```bash
ubuntu@ubuntu:~$ nix flake show github:ES-Nix/podman-rootless/from-nixpkgs
github:ES-Nix/podman-rootless/65d5bfda7744618d763c681b31d00cca5c3b9278
├───defaultPackage
│   ├───aarch64-linux: package 'podman-rootless-derivation'
│   ├───i686-linux: package 'podman-rootless-derivation'
│   ├───x86_64-darwin: package 'podman-rootless-derivation'
│   └───x86_64-linux: package 'podman-rootless-derivation'
├───devShell
│   ├───aarch64-linux: development environment 'nix-shell'
│   ├───i686-linux: development environment 'nix-shell'
│   ├───x86_64-darwin: development environment 'nix-shell'
│   └───x86_64-linux: development environment 'nix-shell'
└───packages
    ├───aarch64-linux
    │   └───podman: package 'podman-rootless-derivation'
    ├───i686-linux
    │   └───podman: package 'podman-rootless-derivation'
    ├───x86_64-darwin
    │   └───podman: package 'podman-rootless-derivation'
    └───x86_64-linux
        └───podman: package 'podman-rootless-derivation'
```

`-cpu Haswell-noTSX-IBRS,vmx=on`
https://stackoverflow.com/a/54221417


nix-shell \
-I nixpkgs=channel:nixos-21.05 \
--packages nixFlakes \
--run \
nix \
profile \
install \
nixpkgs#home-manager

nix profile install nixpkgs#nixFlakes

