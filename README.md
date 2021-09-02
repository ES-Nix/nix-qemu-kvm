

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
nix shell nixpkgs#coreutils --command timeout 60 result/runVML
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
rg -o 'vmx\|svm' /proc/cpuinfo || echo 'Error'
stat --format=%G /dev/kvm | rg 'kvm' || echo 'Error'
rg -o 'vmx\|svm' /proc/cpuinfo | wc --lines | rg 8 || echo 'Error'
rg "^Mem" /proc/meminfo || echo 'Error'
```
Adapted from: https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/ e https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/
grep -o 'vmx\|svm' /proc/cpuinfo


```bash
sudo su -c "echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf" \
sudo reboot
```

Commands to test:
```bash
cat /etc/modprobe.d/kvm.conf | grep kvm_
cat /sys/module/kvm_intel/parameters/nested
grep -o 'vmx\|svm' /proc/cpuinfo
grep -o 'vmx\|svm' /proc/cpuinfo | wc --lines | grep 8
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

--mount source="$NIX_CACHE_VOLUME",target=/nix \

docker \
run \
--device=/dev/kvm \
--interactive=true \
--privileged=true \
--tty=false \
--rm=true \
--volume '/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes \
    <<COMMANDS
mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
echo begined
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare
echo 1
timeout 60 result/runVM
echo 2
COMMANDS
```

```bash
podman \
run \
--cap-add=ALL \
--device=/dev/kvm \
--interactive=true \
--mount source="$NIX_CACHE_VOLUME",target=/nix \
--privileged=true \
--tty=false \
--rm=true \
--volume '/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
echo begined
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare-l
echo 1
timeout 60 result/runVML
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


```
sudo \
sed \
--in-place \
's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1"/' \
/etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg \
&& sudo reboot
```

```bash
ls -al /sys/fs/cgroup | rg -e 'cgroup.'
```

```bash
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.subtree_control

sudo mkdir -p /etc/systemd/system/user@.service.d
sudo cat > /etc/systemd/system/user@.service.d/delegate.conf << EOF
[Service]
Delegate=yes
EOF
```


wget https://github.com/rootless-containers/usernetes/releases/download/v20210708.0/usernetes-x86_64.tbz \
&& tar xjvf usernetes-x86_64.tbz \
&& cd usernetes \
&& ./install.sh --cri=containerd

nix \
profile \
install \
nixpkgs#wget \
github:ES-Nix/podman-rootless/from-nixpkgs


podman \
stats \
--cgroup-manager=systemd


sudo apt-get install -y systemd
sudo apt-get update &&
&& sudo apt-get install -y dbus-user-session

env | rg DBUS_SESSION_BUS_ADDRESS
systemctl --user status dbus.socket

systemctl --user enable --now dbus.socket


lsb_release --all
uname --all

systemd --version
https://github.com/rootless-containers/usernetes#requirements


podman \
run \
--cgroup-manager=cgroupfs \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=true \
--tty=false \
--rm=true \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=0755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& mkdir --parent --mode=0755 /var/tmp \
&& podman \
run \
--events-backend="file" \
--storage-driver="vfs" \
--cgroups=disabled \
--log-level=error \
--interactive=true \
--network=host \
--tty=true \
docker.io/library/alpine:3.14.0 \
sh \
-c 'apk add --no-cache curl && echo PinP'
COMMANDS


podman \
run \
--cgroup-manager=cgroupfs \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=true \
--tty=true \
--rm=true \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
docker.nix-community.org/nixpkgs/nix-flakes



###


### SELinux



```bash
sudo systemctl stop apparmor \
&& sudo apt-get remove -y apparmor \
&& sudo reboot
```


```bash
sudo \
apt-get \
update \
&& sudo \
apt-get \
install \
-y \
policycoreutils \
selinux-utils \
selinux-basics \
&& sudo selinux-activate \
&& sudo \
    sed \
    --in-place \
    's/^SELINUX=permissive/SELINUX=disabled/' \
    /etc/selinux/config \
&& sudo reboot
```

```bash
sudo \
    sed \
    --in-place \
    's/^SELINUX=disabled/SELINUX=permissive/' \
    /etc/selinux/config \
&& sudo reboot
```

```bash
sudo \
    sed \
    --in-place \
    's/^SELINUX=permissive/SELINUX=enforcing/' \
    /etc/selinux/config \
&& sudo reboot
```

```bash
sed \
--in-place \
's/^SELINUX=enforcing/SELINUX=permissive/' \
/etc/selinux/config \
&& reboot
```

`! stat /etc/selinux/config || cat /etc/selinux/config | grep -e '^SELINUX='`


- https://linuxconfig.org/how-to-disable-enable-selinux-on-ubuntu-20-04-focal-fossa-linux
- https://www.techrepublic.com/article/how-to-install-selinux-on-ubuntu-server-20-04/
- https://askubuntu.com/a/1304946
- https://www.golinuxcloud.com/disable-selinux/
- https://howto.lintel.in/enable-disable-selinux-centos/
- https://newbedev.com/selinux-corrupted-now-unable-to-boot-centos-7-with-selinux-enabled
- https://access.redhat.com/discussions/3536621
- https://serverfault.com/questions/824975/failed-to-get-d-bus-connection-operation-not-permitted
- https://serverfault.com/questions/936985/cannot-use-systemctl-user-due-to-failed-to-get-d-bus-connection-permission
- https://man7.org/linux/man-pages/man5/selinux_config.5.html   


```bash
echo 'Start instalation!' \
&& echo 'Start nix stuff...' \
&& test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=7c60027233ae556d73592d97c074bc4f3fea451d \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="$(readlink -f $(which nix))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version \
&& echo 'End nix stuff...' \
&& echo 'Start kvm stuff...' \
&& getent group kvm || sudo groupadd kvm \
&& sudo usermod --append --groups kvm "$USER" \
&& echo 'End kvm stuff!' \
&& echo 'Start cgroup v2 instalation...' \
&& sudo mkdir -p /etc/systemd/system/user@.service.d \
&& sudo sh -c "echo '[Service]' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo sh -c "echo 'Delegate=yes' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo \
    sed \
    --in-place \
    's/^GRUB_CMDLINE_LINUX="/&cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1 cgroup_no_v1=all/' \
    /etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg \
&& echo 'End cgroup v2 instalation...' \
&& echo 'Start docker instalation...' \
&& curl -fsSL https://get.docker.com | sudo sh \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& echo 'End docker instalation!' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'Start SELinux instalation!' \
&& sudo \
    apt-get \
    update \
&& sudo \
    apt-get \
    install \
    -y \
    policycoreutils \
    selinux-utils \
    selinux-basics \
&& sudo apt-get -y autoremove \
&& sudo apt-get -y clean  \
&& sudo rm -rf /var/lib/apt/lists/* \
&& sudo selinux-activate \
&& sudo \
    sed \
    --in-place \
    's/^SELINUX=permissive/SELINUX=disabled/' \
    /etc/selinux/config \
&& sudo \
    sed \
    --in-place \
    's/^SELINUXTYPE=permissive/SELINUX=disabled/' \
    /etc/selinux/config \
&& echo 'End SELinux instalation!' \
&& nix \
    profile \
    install \
    github:ES-Nix/podman-rootless/from-nixpkgs \
    nixpkgs#bashInteractive \
    nixpkgs#conntrack-tools \
    nixpkgs#coreutils \
    nixpkgs#file \
    nixpkgs#findutils \
    nixpkgs#gnumake \
    nixpkgs#jq \
    nixpkgs#minikube \
    nixpkgs#kubernetes-helm \
    nixpkgs#python3Full \
    nixpkgs#python3Full.pkgs.pip \
    nixpkgs#python3Full.pkgs.setuptools \
    nixpkgs#python3Full.pkgs.virtualenv \
    nixpkgs#python3Full.pkgs.wheel \
    nixpkgs#ripgrep \
    nixpkgs#strace \
    nixpkgs#tree \
    nixpkgs#which \
&& nix store gc \
&& sudo reboot
```



&& echo 'Start kubectl instalation...' \
&& curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
&& sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
&& echo 'End kubectl instalation!' \

&& echo 'Start minikube instalation...' \
&& curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
&& sudo install minikube-linux-amd64 /usr/local/bin/minikube \
&& echo 'End minikube instalation!' \

```bash
echo
cat /sys/fs/cgroup/cgroup.subtree_control | grep -e 'cpu' || echo 'Error'
cat /sys/fs/cgroup/cgroup.subtree_control | grep -e 'cpuset' || echo 'Error'
cat /sys/fs/cgroup/cgroup.subtree_control | grep -e 'io' || echo 'Error'
cat /sys/fs/cgroup/cgroup.subtree_control | grep -e 'memory' || echo 'Error'
cat /sys/fs/cgroup/cgroup.subtree_control | grep -e 'pids' || echo 'Error'
echo 
cat /sys/fs/cgroup/user.slice/cgroup.subtree_control | grep -e 'cpu' || echo 'Error'
cat /sys/fs/cgroup/user.slice/cgroup.subtree_control | grep -e 'cpuset' || echo 'Error'
cat /sys/fs/cgroup/user.slice/cgroup.subtree_control | grep -e 'io' || echo 'Error'
cat /sys/fs/cgroup/user.slice/cgroup.subtree_control | grep -e 'memory' || echo 'Error'
cat /sys/fs/cgroup/user.slice/cgroup.subtree_control | grep -e 'pids' || echo 'Error'
echo
systemctl show user@$(id -u).service | rg Accounting
systemctl show user@$(id -u).service | rg Delegate
echo 
mount -l | grep cgroup2 | grep -e 'type cgroup2' || echo 'Error'
ls -al /sys/fs/cgroup | grep -e 'cgroup.'
! stat /etc/default/grub || cat /etc/default/grub | grep -e 'systemd.unified_cgroup_hierarchy=1'
! stat /etc/default/grub || cat /etc/default/grub | grep -e 'cgroup_no_v1=all'
cat /etc/group | rg -e 'kvm:'
ls -al /sys/fs/cgroup | rg -e 'cgroup.'
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.subtree_control | rg -e 'memory' || echo 'Error'
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.subtree_control | rg -e 'pids' || echo 'Error'
groups | rg 'kvm' || echo 'Error'
stat --format=%G /dev/kvm | rg 'kvm' || echo 'Error'
cat /sys/module/kvm_intel/parameters/nested | rg 'Y' || echo 'Error'
modinfo kvm_intel | rg -i nested || echo 'Error'
rg -o 'vmx|svm' /proc/cpuinfo | wc --lines | rg 8 || echo 'Error'
rg "^Mem" /proc/meminfo || echo 'Error'
systemctl --user status dbus.socket | rg active
cat /proc/cmdline
```


```bash
podman \
run \
--interactive=true \
--memory-reservation=200m \
--memory=300m \
--memory-swap=300m \
--rm=true \
--tty=true \
docker.io/library/alpine:3.14.0 \
echo \
'Hi!'
```

nix build github:ES-Nix/poetry2nix-examples/2cb6663e145bbf8bf270f2f45c869d69c657fef2#poetry2nixOCIImage


```bash
minikube start \
&& kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4 \
&& kubectl expose deployment hello-minikube --type=NodePort --port=8080 \
&& sleep 5 \
&& kubectl get services hello-minikube
```

alias kubectl='minikube kubectl'
alias k='minikube kubectl'

```bash
kubectl exec name -- command
``` 



https://www.baeldung.com/ops/kubernetes-helm#developing_first_chart

```
minikube start
helm create hello-world

helm install hello-world ./hello-world

kubectl get pods

helm ls --all | rg hello-world

helm upgrade hello-world ./hello-world

helm delete hello-world
```


nix profile install nixpkgs#docker

```bash
podman system service --time=0 unix://tmp/podman.sock &
```


```bash
docker \
--host=unix:///tmp/podman.sock \
run \
--interactive=true \
--tty=true \
--rm=true \
docker.io/library/alpine:3.14.0 \
echo 'Hello!'
```

Does not work:
```bash
sudo mkdir -p /etc/sysconfig
sudo sh -c 'echo DOCKER_OPTS=\"-H unix:///tmp/podman.sock -H tcp://172.17.0.1:2375\" >> /etc/sysconfig/docker'
```

podman system service --time=0 unix://var/run/docker.sock &
echo "$(which docker)"
sudo rm -r /etc/sysconfig/docker

#### Refs

- https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
- https://minikube.sigs.k8s.io/docs/start/  


- https://github.com/rootless-containers/usernetes/tree/097d99e78e7a026093cad0057e0065ce407a94a4#enable-cpu-controller
- https://rootlesscontaine.rs/getting-started/common/cgroup2/#checking-whether-cgroup-v2-is-already-enabled
- https://github.com/containers/podman/issues/6365#issuecomment-719550618
- https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities
- https://serverfault.com/a/885689
- https://stackoverflow.com/a/68026463
- https://mbien.dev/blog/tags/debian
- https://stackoverflow.com/a/66827343
- 
