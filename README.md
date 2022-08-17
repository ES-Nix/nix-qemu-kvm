

To run using `nix + flakes`:

First working relevant commit:
`nix develop github:ES-Nix/nix-qemu-kvm/23f67f69d185979829ae8fef9574a23b7f2b7525`


```bash
nix build github:ES-Nix/nix-qemu-kvm/51c7b855f579d806969bef8d93b3ff96830ff294#qemu.prepare
./result/runVM
```

```bash
nix \
develop \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
bash \
-c \
'nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& vm-kill; \
   nix run github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm'
```

```bash
nix \
run \
github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm 
```


```bash
nix \
run \
github:ES-Nix/nix-qemu-kvm/dba4650119c30f768069651ba375009290c51f83#ubuntu-qemu-kvm
```


```bash
nix \
run \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm
```


```bash
nix \
run \
--refresh \
.#ubuntu-qemu-kvm
```


```bash
nix \
develop \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
bash \
-c "ubuntu-qemu-kvm && exec $(ps -ocomm= -q $$)"
```

```bash
nix run --refresh github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm-with-volume -- --backup 'true'
```

```bash
nix run --refresh github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm-with-volume-and-nix -- --backup 'true'
```

```bash
nix run --refresh .#ubuntu-qemu-kvm-with-volume -- --backup 'true'
```

```bash
nix \
develop \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
bash \
-c "ubuntu-qemu-kvm-with-volume --backup 'true' && exec $(ps -ocomm= -q $$)"
```

```bash
nix \
develop \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
bash \
-c "ubuntu-qemu-kvm-with-volume-and-nix --backup 'true' && exec $(ps -ocomm= -q $$)"
```

```bash
nix \
develop \
--refresh \
.# \
--command \
bash \
-c "ubuntu-qemu-kvm-with-volume --backup 'true' && exec $(ps -ocomm= -q $$)"
```


```bash
echo "$(id -un):123" | sudo chpasswd

sudo sed -i 's/^[^#]*'"$(id -un)"' ALL=(ALL) NOPASSWD:ALL/# &/' /etc/sudoers.d/90-cloud-init-users
```

## Installing via git


```bash
git clone https://github.com/ES-Nix/nix-qemu-kvm.git \
&& cd nix-qemu-kvm \
&& git checkout c16c4bed78398af43cd3d3f0f1ddb4491df5f479 \
&& nix build .#myqemu.prepare \
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


## Troubleshooting a bug in my setup with poetry2nix

```
echo 'b' | sudo --stdin sed --in-place '/rootALL=(ALL:ALL) ALL/a ubuntuALL=(ALL:ALL) ALL' /etc/sudoers
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


It is not totally working:
```bash
sudo groupadd kvm
sudo usermod --append --groups kvm "$USER"
sudo chown -R "$USER":kvm /dev/kvm /dev/pts /dev/ptmx
```

```bash
ubuntu@ubuntu:~$ stat /dev/kvm /dev/pts /dev/ptmx
File: /dev/kvm
Size: 0 Blocks: 0IO Block: 4096 character special file
Device: 6h/6d Inode: 346 Links: 1 Device type: a,e8
Access: (0600/crw-------)Uid: ( 1000/ubuntu) Gid: ( 1001/ kvm)
Access: 2021-06-26 20:14:26.260000000 +0000
Modify: 2021-06-26 20:14:26.260000000 +0000
Change: 2021-06-26 20:15:24.287113618 +0000
 Birth: -
File: /dev/pts
Size: 0 Blocks: 0IO Block: 1024 directory
Device: 15h/21d Inode: 1 Links: 2
Access: (0755/drwxr-xr-x)Uid: ( 1000/ubuntu) Gid: ( 1001/ kvm)
Access: 2021-06-26 20:15:24.287113618 +0000
Modify: 2021-06-26 20:14:20.672000000 +0000
Change: 2021-06-26 20:15:24.287113618 +0000
 Birth: -
File: /dev/ptmx
Size: 0 Blocks: 0IO Block: 4096 character special file
Device: 6h/6d Inode: 86Links: 1 Device type: 5,2
Access: (0666/crw-rw-rw-)Uid: ( 1000/ubuntu) Gid: ( 1001/ kvm)
Access: 2021-06-26 20:14:25.900000000 +0000
Modify: 2021-06-26 20:14:25.900000000 +0000
Change: 2021-06-26 20:15:24.287113618 +0000
 Birth: -
```

After `sudo reboot` it does not keep the permissions:

```bash
ubuntu@ubuntu:~$ stat /dev/kvm /dev/pts /dev/ptmx
File: /dev/kvm
Size: 0 Blocks: 0IO Block: 4096 character special file
Device: 6h/6d Inode: 346 Links: 1 Device type: a,e8
Access: (0600/crw-------)Uid: (0/root) Gid: (0/root)
Access: 2021-06-26 20:14:26.260000000 +0000
Modify: 2021-06-26 20:14:26.260000000 +0000
Change: 2021-06-26 20:14:26.260000000 +0000
 Birth: -
File: /dev/pts
Size: 0 Blocks: 0IO Block: 1024 directory
Device: 15h/21d Inode: 1 Links: 2
Access: (0755/drwxr-xr-x)Uid: (0/root) Gid: (0/root)
Access: 2021-06-26 20:14:20.672000000 +0000
Modify: 2021-06-26 20:14:20.672000000 +0000
Change: 2021-06-26 20:14:20.672000000 +0000
 Birth: -
File: /dev/ptmx
Size: 0 Blocks: 0IO Block: 4096 character special file
Device: 6h/6d Inode: 86Links: 1 Device type: 5,2
Access: (0666/crw-rw-rw-)Uid: (0/root) Gid: (5/ tty)
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
&& sudo reboot
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

In NixOS:
```bash
boot.kernelModules = [ "kvm-intel" ];
boot.extraModprobeConfig = "options kvm_intel nested=1";
```
From: https://github.com/NixOS/nixpkgs/issues/27930#issuecomment-417943781

About `libvirt`: https://nixos.wiki/wiki/Libvirt


#### Requirements for KVM 

- https://wiki.archlinux.org/title/KVM#Checking_support_for_KVM

# Burn cache, as it may make you waste a lot of time!

--mount source="$NIX_CACHE_VOLUME",target=/nix \
--mount source="$NIX_CACHE_VOLUME",target=/home/pedroregispoar/.cache/ \
--mount source="$NIX_CACHE_VOLUME",target=/home/pedroregispoar/.config/nix/ \
--mount source="$NIX_CACHE_VOLUME",target=/home/pedroregispoar/.nix-defexpr/ \

NIX_CACHE_VOLUME='nix-cache-volume'

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
│ ├───aarch64-linux: package 'podman-rootless-derivation'
│ ├───i686-linux: package 'podman-rootless-derivation'
│ ├───x86_64-darwin: package 'podman-rootless-derivation'
│ └───x86_64-linux: package 'podman-rootless-derivation'
├───devShell
│ ├───aarch64-linux: development environment 'nix-shell'
│ ├───i686-linux: development environment 'nix-shell'
│ ├───x86_64-darwin: development environment 'nix-shell'
│ └───x86_64-linux: development environment 'nix-shell'
└───packages
├───aarch64-linux
│ └───podman: package 'podman-rootless-derivation'
├───i686-linux
│ └───podman: package 'podman-rootless-derivation'
├───x86_64-darwin
│ └───podman: package 'podman-rootless-derivation'
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


```bash
nix \
profile \
install \
nixpkgs#wget \
nixpkgs#bzip2 \
nixpkgs#kubectl \
nixpkgs#fuse3 \
nixpkgs#iptables \
nixpkgs#conntrack-tools \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version
```

```bash
wget https://github.com/rootless-containers/usernetes/releases/download/v20210708.0/usernetes-x86_64.tbz \
&& tar xjvf usernetes-x86_64.tbz \
&& cd usernetes \
&& ./install.sh --cri=containerd
```


grep "^$(whoami):" /etc/sub?id

MODULE=fuse
sudo modinfo "$MODULE" 1> /dev/null 2> /dev/null \
&& ! sudo modprobe -n --first-time "$MODULE" 2> /dev/null \
&& echo "Loaded" || modprobe "$MODULE"

Refs.:
- https://stackoverflow.com/a/30311688


```bash
cat <<EOF | xargs sudo modprobe
br_netfilter
bridge
fuse
ip6_tables
ip6table_filter
ip6table_nat
ip_tables
iptable_filter
iptable_nat
nf_tables
tap
tun
veth
x_tables
xt_MASQUERADE
xt_addrtype
xt_comment
xt_conntrack
xt_mark
xt_multiport
xt_nat
xt_tcpudp
EOF
```


podman ps



docker cp usernetes-node:/home/user/.config/usernetes/master/admin-localhost.kubeconfig docker.kubeconfig
export KUBECONFIG=./docker.kubeconfig
kubectl run -it --rm --image busybox foo

kubectl get nodes -o wide


docker \
run \
-td \
--name usernetes-node \
-p 127.0.0.1:6443:6443 \
--privileged \
ghcr.io/rootless-containers/usernetes \
--cri=containerd

&& getent group docker || sudo groupadd docker \

podman \
stats \
--cgroup-manager=systemd


sudo apt-get install -y systemd
sudo apt-get update &&
&& sudo apt-get install -y dbus-user-session

printenv DBUS_SESSION_BUS_ADDRESS
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

```bash
! stat /etc/selinux/config || cat /etc/selinux/config | grep -e '^SELINUX='
```


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
echo 'Start kvm stuff...' \
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
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo 'Start uidmap instalation!' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'End uidmap instalation!' \
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
&& sudo apt-get -y clean\
&& sudo rm -rf /var/lib/apt/lists/* \
&& sudo selinux-activate \
&& sudo \
sed \
--in-place \
's/^SELINUX=permissive/SELINUX=disabled/' \
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
nixpkgs#ripgrep \
nixpkgs#strace \
nixpkgs#tree \
nixpkgs#which \
&& nix store gc \
&& sudo reboot
```

```bash
result/ssh-vm << COMMANDS
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "\$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"\$SHA256"/get-nix.sh | sh \
&& . "\$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."\$(ps -ocomm= -q \$$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="\$(readlink -f \$(which nix))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall \$OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version
COMMANDS
```

```bash
{ result/ssh-vm << COMMANDS
date
echo '#1'
COMMANDS
} && { result/ssh-vm << COMMANDS
date
echo '#2'
COMMANDS
} && result/ssh-vm << COMMANDS
date
echo '#3'
COMMANDS
```



```bash
minikube start --driver=podman --container-runtime=cri-o
```

```bash
kill -9 $(pidof qemu-system-x86_64) || true \
&& result/refresh || nix build .#qemu.vm \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "\$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"\$SHA256"/get-nix.sh | sh \
&& . "\$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."\$(ps -ocomm= -q \$\$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="\$(readlink -f \$(which nix))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall \$OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version
COMMANDS
} && result/backupCurrentState nix-flake \
&& { result/ssh-vm << COMMANDS
echo 'Start kvm stuff...' \
&& getent group kvm || sudo groupadd kvm \
&& sudo usermod --append --groups kvm "\$USER" \
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
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo 'Start uidmap instalation!' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'End uidmap instalation!' \
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
&& sudo apt-get -y clean\
&& sudo rm -rf /var/lib/apt/lists/* \
&& sudo selinux-activate \
&& sudo \
sed \
--in-place \
's/^SELINUX=permissive/SELINUX=disabled/' \
/etc/selinux/config \
&& echo 'End SELinux instalation!' \
&& nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
nixpkgs#cni \
nixpkgs#cni-plugins \
nixpkgs#conntrack-tools \
nixpkgs#cri-o \
nixpkgs#file \
nixpkgs#findutils \
nixpkgs#kubernetes-helm \
nixpkgs#minikube \
nixpkgs#ripgrep \
nixpkgs#slirp4netns \
nixpkgs#strace \
nixpkgs#which \
&& sudo ln -fsv /home/ubuntu/.nix-profile/bin/podman /usr/bin/podman \
&& sudo mkdir -p /usr/lib/cni \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/portmap /usr/lib/cni/portmap \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/firewall /usr/lib/cni/firewall \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/tuning /usr/lib/cni/tuning \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/bridge /usr/lib/cni/bridge \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cri-o)"/bin/crio /usr/lib/crio \
&& echo 'Start bypass sudo podman stuff...' \
&& sudo \
--preserve-env \
su \
-c \
"echo \$USER ALL=\(ALL\) NOPASSWD:SETENV: \$(readlink \$(which podman)) >> /etc/sudoers" \
&& echo 'End bypass sudo podman stuff...' \
&& nix store gc \
&& sudo reboot
COMMANDS
} && result/backupCurrentState wip-01 \
&& echo 'End of backup wip-01' \
&& kill -9 $(pidof qemu-system-x86_64) \
&& result/refresh \
&& result/resetToBackup wip-01 \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
minikube start --driver=podman
COMMANDS
} && kill -9 $(pidof qemu-system-x86_64) \
&& result/refresh \
&& result/resetToBackup wip-01 \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
minikube start --driver=podman --container-runtime=cri-o
COMMANDS
}
```




```bash
echo 'Start docker instalation...' \
&& curl -fsSL https://get.docker.com | sudo sh \
&& getent group docker || sudo groupadd docker \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& echo 'End docker instalation!'
```

```bash
nixpkgs#python3Full \
nixpkgs#python3Full.pkgs.pip \
nixpkgs#python3Full.pkgs.setuptools \
nixpkgs#python3Full.pkgs.virtualenv \
nixpkgs#python3Full.pkgs.wheel \
```

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

```bash
alias kubectl='minikube kubectl'
minikube start
helm create hello-world

helm install hello-world ./hello-world

kubectl get pods

helm ls --all | rg hello-world

helm upgrade hello-world ./hello-world

helm delete hello-world
```


kubectl get pods
minikube kubectl -- apply -f pod.yalm 
kubectl get pods

minikube kubectl exec -- -it test-subpath-hostpath bash
kubectl exec -- --stdin --tty test-subpath-hostpath -- /bin/bash -c 'ls -al'

minikube kubectl -- delete -f pod.yalm



kubectl apply -- -f https://k8s.io/examples/application/shell-demo.yaml
kubectl get pod shell-demo

minikube kubectl -- delete shell-demo 

kubectl exec -- --stdin --tty shell-demo -- /bin/bash -c 'ls -al /'
kubectl exec -- --stdin --tty shell-demo -- /bin/bash -c 'touch /usr/share/nginx/html/foo.txt'

```bash
cat << EOF > pod.yalm 
apiVersion: v1
kind: Pod
metadata:
name: shell-demo
spec:
volumes:
- name: shared-data
emptyDir: {}
containers:
- name: nginx
image: nginx
volumeMounts:
- name: shared-data
mountPath: /data
volumes:
- hostPath:
path: /data
type: Directory
name: shared-data
hostNetwork: true
dnsPolicy: Default
EOF

kubectl apply -- -f pod.yalm

sleep 5
kubectl get pods
kubectl exec -- --stdin --tty shell-demo -- /bin/bash -c 'ls -al /data'

minikube kubectl -- delete -f pod.yalm
```

```bash
cat << EOF > pod-test-subpath-hostpath.yaml
apiVersion: v1
kind: Pod
metadata:
name: test-subpath-hostpath
labels:
app: test-subpath-hostpath
spec:
containers:
- name: nginx
image: ubuntu
command:
- sleep
- "3600"
volumeMounts:
- name: data
mountPath: /data
volumes:
- hostPath:
path: /data/disk0
type: Directory
name: data
EOF

kubectl apply -- -f pod-test-subpath-hostpath.yaml
kubectl get pods
kubectl exec -- --stdin --tty test-subpath-hostpath -- /bin/bash -c 'ls -al /data'

minikube kubectl -- delete pod test-subpath-hostpath
rm -fv pod-test-subpath-hostpath.yaml
```

```bash
cat << EOF > myVolumes-Pod.yaml
apiVersion: v1
kind: Pod
metadata:
name: myvolumes-pod
spec:
containers:
- image: alpine
imagePullPolicy: IfNotPresent
name: myvolumes-container

command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 3600']

volumeMounts:
- mountPath: /home/ubuntu/volume-test/
name: demo-volume
volumes:
- name: demo-volume
hostPath:
# directory location on host
path: /home/ubuntu/volume-test/
EOF

kubectl create -- -f myVolumes-Pod.yaml
kubectl get pods
kubectl exec myvolumes-pod -- -i -t -- /bin/sh -c 'echo text-abc > /demo/textfile.txt'

minikube kubectl -- delete pod myvolumes-pod
rm -fv myVolumes-Pod.yaml
```


```bash
cat << EOF > example-pod.yaml
apiVersion: v1
kind: Pod
metadata:
name: test-pd
spec:
containers:
- image: alpine
imagePullPolicy: IfNotPresent
name: volume-container
command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 3600']

volumeMounts:
- mountPath: /code
name: test-volume
volumes:
- name: test-volume
hostPath:
# directory location on host
path: /home/ubuntu/volume-test
# this field is optional
type: Directory
EOF

kubectl create -- -f example-pod.yaml
kubectl get pods
kubectl exec volume-container -- -i -t -- /bin/sh -c 'echo text-abc > demo/textfile'

minikube kubectl -- delete pod test-pd
rm -fv example-pod.yaml
```


my-lamp-site

```bash
cat << EOF > my-lamp-site.yaml
apiVersion: v1
kind: Pod
metadata:
name: my-lamp-site
spec:
containers:
- name: mysql
image: mysql
env:
- name: MYSQL_ROOT_PASSWORD
value: "rootpasswd"
volumeMounts:
- mountPath: /var/lib/mysql
name: site-data
subPath: mysql
- name: php
image: php:7.0-apache
volumeMounts:
- mountPath: /var/www/html
name: site-data
subPath: html
volumes:
- name: site-data
persistentVolumeClaim:
claimName: my-lamp-site-data
EOF

kubectl create -- -f my-lamp-site.yaml

kubectl get pods

kubectl exec my-lamp-site -- -i -t -- /bin/bash -c 'ls -al /'
kubectl exec mysql -- -i -t -- /bin/bash -c 'ls -al /'
kubectl exec mysql -- -i -t -- /bin/bash -c 'echo text-abc > demo/textfile'

minikube kubectl -- delete pod my-lamp-site
rm -fv example-pod.yaml
```


```bash
cat << EOF > my-lamp-site.yaml
apiVersion: v1
kind: Pod
metadata:
name: my-alpine
spec:
containers:
- name: mysql
image: alpine
volumeMounts:
- mountPath: /var/lib/mysql
name: site-data
subPath: mysql
- name: alpine
image: alpine:3.14.0
volumeMounts:
- mountPath: /var/www/html
name: site-data
subPath: html
volumes:
- name: site-data
persistentVolumeClaim:
claimName: my-lamp-site-data
EOF

kubectl create -- -f my-lamp-site.yaml

kubectl get pods

kubectl exec my-alpine -- -i -t -- /bin/bash -c 'ls -al /'
kubectl exec mysql -- -i -t -- /bin/bash -c 'ls -al /'
kubectl exec mysql -- -i -t -- /bin/bash -c 'echo text-abc > demo/textfile'

minikube kubectl -- delete pod my-lamp-site
rm -fv example-pod.yaml
```



```bash
cat << EOF > example-pod.yaml
apiVersion: v1
kind: Pod
metadata:
name: test-volume
spec:
containers:
- image: alpine
imagePullPolicy: IfNotPresent
name: volume-container
command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 3600']

volumeMounts:
- mountPath: /code
name: test-volume
volumes:
- name: test-volume
hostPath:
# directory location on host
path: /home
# this field is optional
type: Directory
EOF

kubectl create -- -f example-pod.yaml
kubectl get pods
kubectl exec test-volume -- -i -t -- /bin/sh -c 'echo text-abc > /code/textfile'

minikube kubectl -- delete pod test-volume
rm -fv example-pod.yaml
```

```bash
cat << EOF > example-pod-with-volume.yaml
apiVersion: v1
kind: Pod
metadata:
name: pod1
spec:
containers:
- name: container1
env:
- name: POD_NAME
valueFrom:
fieldRef:
apiVersion: v1
fieldPath: metadata.name
image: busybox
command: [ "sh", "-c", "while [ true ]; do echo 'Hello'; sleep 3; done | tee -a /logs/hello.txt" ]
volumeMounts:
- name: workdir1
mountPath: /home/ubuntu/sandbox/sandbox
subPath: sandbox
restartPolicy: Never
volumes:
- name: workdir1
hostPath:
path: /home/ubuntu/sandbox/sandbox
EOF

minikube kubectl create -- -f example-pod-with-volume.yaml
minikube kubectl get pods
minikube kubectl exec pod1 -- -i -t -- /bin/sh -c 'ls -al /home/ubuntu/sandbox/sandbox'
minikube kubectl exec pod1 -- -i -t -- /bin/sh -c 'cat /home/ubuntu/sandbox/sandbox/hello.txt | wc -l'

minikube kubectl -- delete pod pod1
rm -fv example-pod-with-volume.yaml
```


2)
```bash
cat << EOF > projected.yaml
apiVersion: v1
kind: Pod
metadata:
name: test-projected-volume
spec:
containers:
- name: test-projected-volume
image: busybox
args:
- sleep
- "86400"
volumeMounts:
- name: all-in-one
mountPath: "/projected-volume"
readOnly: false
volumes:
- name: all-in-one
projected:
sources:
- secret:
name: user
- secret:
name: pass
EOF

# Create files containing the username and password:
echo -n "admin" > ./username.txt
echo -n "1f2d1e2e67df" > ./password.txt

# Package these files into secrets:
minikube kubectl create secret generic user -- --from-file=./username.txt
minikube kubectl create secret generic pass -- --from-file=./password.txt

minikube kubectl create -- -f projected.yaml
minikube kubectl get pods
minikube kubectl exec test-projected-volume -- -i -t -- /bin/sh -c 'cat /projected-volume/password.txt'
minikube kubectl exec test-projected-volume -- -i -t -- /bin/sh -c 'echo abc123 >> /projected-volume/foo.txt'
minikube kubectl exec test-projected-volume -- -i -t -- /bin/sh

minikube kubectl -- delete pod test-projected-volume
rm -fv projected.yaml
```


3)
```bash
cat << EOF > projected.yaml
apiVersion: v1
kind: Pod
metadata:
name: test-pod
spec:
containers:
- name: test-pod
image: busybox
command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 3600']
EOF

minikube kubectl create -- -f projected.yaml
minikube kubectl get pods
sleep 10
minikube kubectl get pods
minikube kubectl exec test-pod -- -i -t -- /bin/sh -c ' ls -al /'

minikube kubectl -- delete pod test-pod
rm -fv projected.yaml
```


4)
```bash
cat << EOF > pod-volume.yaml
apiVersion: v1
kind: Pod
metadata:
name: test-pod-volume
spec:
containers:
- name: test-pod-volume
image: busybox
command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 3600']
volumeMounts:
- name: all-in-one
mountPath: "/home"
readOnly: false
volumes:
- name: all-in-one
hostPath:
# directory location on host
path: /home/ubuntu/sandbox/sandbox
# this field is optional
type: Directory
EOF

minikube kubectl create -- -f pod-volume.yaml
minikube kubectl get pods
minikube kubectl exec test-projected-volume -- -i -t -- /bin/sh -c ' ls -al /home'
minikube kubectl exec test-projected-volume -- -i -t -- /bin/sh

minikube kubectl -- delete pod test-pod-volume
rm -fv pod-volume.yaml.yaml
```

```bash
minikube kubectl describe pod test-pod-volume | rg Volumes --after-context=4
```

```bash
minikube kubectl get ev | rg Failed
```


Deleting all pods:
```bash
minikube kubectl -- delete --all pods --namespace=default
```
Adapted from: https://gist.github.com/sharepointoscar/0c35e6fb9151a1967bd68253b1bf802f


#### How to not use sudo and docker?


Broken:
```bash
minikube start --driver=none
```
From: https://minikube.sigs.k8s.io/docs/drivers/none/#usage


#### Trying the podman socket

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
From: https://www.baeldung.com/ops/docker-engine-api-container-info


podman system service --time=0 unix://var/run/docker.sock &
echo "$(which docker)"
sudo rm -r /etc/sysconfig/docker

May be related? 
- https://github.com/moby/moby/issues/24886
- https://github.com/containers/podman/issues/13108


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


### WIP ssh


```
time ./result/ssh-vm << COMMANDS
echo 'Hi'
id | grep ubuntu
echo 'End'
COMMANDS
```
Adapted from: https://unix.stackexchange.com/a/187980


```bash
echo 'Start!'
nix \
build \
github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& result/run-vm-kvm < /dev/null & result/ssh-vm << COMMANDS
echo 'Hi'
id | grep ubuntu
uname --all
echo 'End'
COMMANDS
```

```bash
echo 'Start!'
nix \
build \
github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& echo 'Build finished!' \
&& (result/run-vm-kvm < /dev/null &) \
&& echo 'Starting ssh to VM' \
&& result/ssh-vm << COMMANDS
echo 'Hi'
id | grep ubuntu
uname --all
echo 'End'
COMMANDS
```

ls && (result/run-vm-kvm < /dev/null &) && result/ssh-vma


```bash
kill -s -KILL $(pidof qemu-system-x86_64)
kill -9 $(pidof qemu-system-x86_64)
```

```bash
nix \
build \
github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& result/run-vm-kvm < /dev/null & result/ssh-vm
```

```bash
result/ssh-vm << COMMANDS
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
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
&& nix flake --version
COMMANDS
```


```bash
echo 'Start instalation!' \
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
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...' \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo 'Start uidmap stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'End uidmap stuff...' \
&& nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix store gc \
&& sudo reboot
```

```bash
result/ssh-vm << COMMANDS
podman \
run \
--interactive=true \
--memory-reservation=200m \
--memory=300m \
--memory-swap=300m \
--rm=true \
--tty=false \
docker.io/library/alpine:3.14.0 \
echo \
'Hi!'
COMMANDS
```



```bash
result/run-vm-kvm < /dev/null &
```

```bash
result/run-vm-kvm&
result/run-vm-kvm &
result/run-vm-kvm > /dev/null 2>&1 &
nohup result/run-vm-kvm > /dev/null 2>&1 &
nohup result/run-vm-kvm > /dev/null &
```




```bash
podman \
run \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=false \
--tty=false \
--rm=true \
--userns=host \
--user=0 \
--volume=/etc/localtime:/etc/localtime:rw \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
localhost/nix-flake-nested-qemu-kvm-vm \
bash \
<< OUTCOMMANDS
result/run-vm-kvm < /dev/null & result/ssh-vm << COMMANDS
echo 'Hi'
id | grep ubuntu
uname --all
echo 'End'
COMMANDS
OUTCOMMANDS
```

```bash
podman \
run \
--deteach=true \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=false \
--log-level=error \
--name=container-qemu-vm \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=false \
--tty=false \
--rm=true \
--userns=host \
--user=0 \
--volume=/etc/localtime:/etc/localtime:rw \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
localhost/nix-flake-nested-qemu-kvm-vm \
bash \
<< OUTCOMMANDS
result/run-vm-kvm
OUTCOMMANDS
```

```bash
podman \
run \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--name=container-qemu-vm \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=false \
--tty=false \
--rm=true \
--userns=host \
--user=0 \
--volume=/etc/localtime:/etc/localtime:rw \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
localhost/nix-flake-nested-qemu-kvm-vm \
bash \
<< OUTCOMMANDS
result/run-vm-kvm < /dev/null & result/ssh-vm << COMMANDS
echo 'Start instalation!' \
&& echo 'Start kvm stuff...' \
&& getent group kvm || sudo groupadd kvm \
&& sudo usermod --append --groups kvm "\$USER" \
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
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...' \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo 'Start uidmap stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'End uidmap stuff...' \
&& nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix store gc \
&& sudo reboot
COMMANDS
OUTCOMMANDS
```

```bash
podman \
exec \
--env=VAR=foo \
--interactive=true \
--log-level=error \
--privileged=true \
--tty=true \
container-qemu-vm \
bash
```

```bash
netstat -tanp | grep 10022

ps aux | rg -e qemu -e COMMAND | rg -v rg

qemu-kvm --help | rg -e '-monitor'
```



#### 

systemd-cgls
systemd --test --system --log-level=debug --no-pager

systemctl status user@$(id -u).service

k3s server --rootless&

sudo apt-get update
sudo apt-get install -y nmap
sudo nmap -sT -O localhost
sudo nmap -sT -O 127.0.0.1
sudo ss -tulwn | grep LISTEN
netstat -nlp


nc -w5 -z -v 127.0.0.53 53


systemctl list-unit-files --state=enabled | rg resolved
systemctl list-unit-files | rg resolved

systemctl disable systemd-resolved.service
sudo reboot

systemctl enable systemd-resolved.service
sudo reboot

k3s server --rootless&
k3s server --rootless --flannel-backend 'host-gw'&
k3s server --rootless --server http://127.0.0.1:6443&
k3s server --rootless --cluster-cidr=10.10.0.0/16&
k3s server --rootless --cluster-cidr=10.42.42.0/24&
k3s server --rootless --cluster-cidr=http://127.0.0.53:53&
k3s server --rootless --cluster-cidr=127.0.0.1:6443 --service-cidr=127.0.0.1:6443&
k3s server --rootless --cluster-cidr=127.0.0.53:53 --service-cidr=127.0.0.53:53&

https://10.41.0.100:6443
127.0.0.1:6443


cat /lib/modules/5.11.0-31-generic/build/.config


k3s --debug server --disable-agent


lsmod | rg -e 'br_netfilter'

env | rg DBUS

systemd-run --user -p Delegate=yes --tty k3s server --rootless --snapshotter=fuse-overlayfs
systemd-run --user -p Delegate=yes --tty k3s server --rootless --disable-agent --snapshotter=fuse-overlayfs

helm --kube-apiserver http://localhost:8080 install hello-world ./hello-world
helm --kube-apiserver http://10.10.0.0/16 install hello-world ./hello-world
helm --kube-apiserver http://10.42.42.0/24 install hello-world ./hello-world
helm --kube-apiserver 127.0.0.1:6443 install hello-world ./hello-world
helm --kube-apiserver http://127.0.0.1:6443 install hello-world ./hello-world
helm --kube-apiserver=0.0.0.0:10080 install hello-world ./hello-world

nc -w5 -z -v 0.0.0.0 10443
nc -w5 -z -v 0.0.0.0 6443 
nc -w5 -z -v 0.0.0.0 10443


systemd-run --user -p Delegate=yes --tty /bin/sh -c 'env'
systemd-run --user -p Delegate=yes --tty /bin/bash -c "PATH=/home/ubuntu/.nix-profile/bin:$PATH exec k3s server --rootless --disable-agent --snapshotter=fuse-overlayfs"


systemd-cgtop
cat /proc/self/cgroup

k3s kubectl get pods




cat << EOF >~/foo
[Unit]
Description=k3s (Rootless)

[Service]
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# NOTE: Don't try to run `k3s server --rootless` on a terminal, as it doesn't enable cgroup v2 delegation.
# If you really need to try it on a terminal, prepend `systemd-run --user -p Delegate=yes --tty` to create a systemd scope.
ExecStart=$(nix eval --raw nixpkgs#k3s)/bin/k3s server --rootless --snapshotter=fuse-overlayfs
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
Type=simple
KillMode=mixed

[Install]
WantedBy=default.target
EOF

mv ~/k3s-rootless.service ~/.config/systemd/user/k3s-rootless.service



### kubectl


mkdir -v ~/config-exercise

kubectl config view
kubectl config current-context


https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts

nix shell nixpkgs#kubectl --command kubectl version --client

ls $([[ ! -z "$KUBECONFIG" ]] && echo "$KUBECONFIG" || echo "$HOME/.kube/config")

mkdir -p ~/.kube/config

cat << EOF > ~/.kube/sa.yml
apiVersion: v1
kind: ServiceAccount
metadata:
name: svcs-acct-dply #any name you'd like
EOF

kubectl create -f ~/.kube/sa.yml


kubectl get pods --server https://localhost:6443

cd ~
echo -n 'admin' > ~/username.txt
echo -n '1f2d1e2e67df' > ~/password.txt

This CLI does not expand `~`!

kubectl \
--server https://localhost:6443 \
create \
secret \
generic \
db-user-pass \
--from-file=username.txt \
--from-file=password.txt


```bash
apiVersion: v1
clusters:
- cluster:
certificate-authority: PATH_TO_SOMEWHERE/.minikube/ca.crt
server: https://172.17.0.3:8443
name: minikube
contexts:
- context:
cluster: minikube
user: minikube
name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
user:
client-certificate: PATH_TO_SOMEWHERE/client.crt
client-key: PATH_TO_SOMEWHERE/client.key
```


### 


```bash
echo 'Start instalation!' \
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
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...' \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo 'Start uidmap stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'End uidmap stuff...' \
&& nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
nixpkgs#cni \
nixpkgs#cni-plugins \
nixpkgs#conntrack-tools \
nixpkgs#fuse-overlayfs \
nixpkgs#kubernetes-helm \
nixpkgs#kvm \
nixpkgs#minikube \
nixpkgs#ripgrep \
nixpkgs#slirp4netns \
nixpkgs#tree \
nixpkgs#which \
&& sudo ln -fsv /home/ubuntu/.nix-profile/bin/podman /usr/bin/podman \
&& sudo mkdir -p /usr/lib/cni \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/portmap /usr/lib/cni/portmap \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/firewall /usr/lib/cni/firewall \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/tuning /usr/lib/cni/tuning \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/bridge /usr/lib/cni/bridge \
&& echo 'Start bypass sudo podman stuff...' \
&& sudo \
--preserve-env \
su \
-c \
"echo $USER ALL=\(ALL\) NOPASSWD:SETENV: $(readlink $(which podman)) >> /etc/sudoers" \
&& echo 'End bypass sudo podman stuff...' \
&& nix store gc \
&& sudo reboot
```

```bash
minikube \
start \
--iso-url=https://vbatts.fedorapeople.org/minikube/minikube.git3358402.iso \
--driver=podman
```

nixpkgs#cri-o
sudo ln -fsv "$(nix eval --raw nixpkgs#cri-o)"/bin/crio /usr/lib/crio

```bash
minikube \
start \
--iso-url=https://vbatts.fedorapeople.org/minikube/minikube.git3358402.iso \
--driver=podman \
--container-runtime=cri-o
```
From: 

minikube \
start \
--iso-url=https://vbatts.fedorapeople.org/minikube/minikube.git3358402.iso \
--driver=podman \
--extra-config=kubelet.container-runtime=remote \
--cni=bridge \
--enable-default-cni


minikube \
start \
--iso-url=https://vbatts.fedorapeople.org/minikube/minikube.git3358402.iso \
--driver=podman \
--extra-config=kubelet.container-runtime=remote \
--cni=bridge \
--enable-default-cni \
--vm-driver=virtualbox


sudo ln -fsv "$(nix eval --raw nixpkgs#kvm)"/bin/qemu-kvm /usr/lib/kvm2
file /usr/lib/kvm2 | rg -e 'kvm'

minikube \
start \
--driver=kvm2



#### 
minikube delete

kubectl get pods


minikube start --driver=kvm

minikube start --driver=podman
minikube start --driver="$(readlink $(which podman))"

minikube \
start \
--iso-url=https://vbatts.fedorapeople.org/minikube/minikube.git3358402.iso \
--driver="$(readlink $(which podman))"

minikube \
start \
--iso-url=[https://storage.googleapis.com/minikube-builds/iso/12268/minikube-v1.22.0-1628974786-12268.iso,https://github.com/kubernetes/minikube/releases/download/v1.22.0-1628974786-12268/minikube-v1.22.0-1628974786-12268.iso,https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/iso/minikube-v1.22.0-1628974786-12268.iso] \
--driver=podman


minikube start --help | grep -e '--iso-url'

nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
nixpkgs#k3s \



####

ps auxww | rg rootlessport | rg -v rg


```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
busybox \
sh \
-c \
'ping google.com'
```

```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
busybox \
sh \
-c \
"ping -W10 -c1 google.com | grep -e '0% packet loss'"
```

```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
ubuntu:21.04 \
bash \
-c \
"apt-get update -y && apt-get install -y iputils-ping && ping -W10 -c1 google.com | grep -e '0% packet loss'"
```


```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
fedora:35 \
bash \
-c \
"yum install -y iputils && ping -W10 -c1 google.com | grep -e '0% packet loss'"
```

```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
fedora:35 \
bash \
-c \
"yum install -y iputils && ping -W10 -c1 google.com | grep -e '0% packet loss'"
```

```bash
podman \
run \
--detach=true \
--name=container-nginx-unprivileged \
--network=host \
--rm=true \
--user=0 \
nginxinc/nginx-unprivileged \
&& curl http://localhost:8080 | rg -e 'Thank you for using nginx.' \
&& podman stop container-nginx-unprivileged \
&& podman rm container-nginx-unprivileged
```
From: Missed it, TODO, find the post. Related: [Publishing Ports](https://podman.io/getting-started/network#publishing-ports) 


#### 

podman pod create -p 8080:80 --name wpapp_pod \
&& podman pod list | rg wpapp_pod \
&& podman ps --all | rg -e 'k8s.gcr.io/pause'

podman \
run \
-d \
--restart=always \
--pod wpapp_pod \
-e MYSQL_ROOT_PASSWORD="myrootpass" \
-e MYSQL_DATABASE="wp-db" \
-e MYSQL_USER="wp-user" \
-e MYSQL_PASSWORD="w0rdpr3ss" \
--name=wptest-db mariadb


#### podman 2 and minikube


https://github.com/kubernetes/minikube/issues/10649



https://4shells.com/nixdb/pkg/podman/2.2.1


```bash
nix \
profile \
install \
nixpkgs/7138a338b58713e0dea22ddab6a6785abec7376a#podman \
nixpkgs#minikube \
nixpkgs#cri-o

sudo apt-get update \
&& sudo apt-get install -y uidmap

sudo \
--preserve-env \
su \
-c \
"echo $USER ALL=\(ALL\) NOPASSWD:SETENV: $(readlink $(which podman)) >> /etc/sudoers"

sudo ln -fsv /home/ubuntu/.nix-profile/bin/podman /usr/bin/podman
sudo ln -fsv "$(nix eval --raw nixpkgs#cri-o)"/bin/crio /usr/lib/crio
```

echo "net.ipv4.ping_group_range=0 429496729" > /etc/sysctl.d/03-non-root-icmp.conf

podman --version | rg -e 'podman version 3.0.1'
```bash
nix \
profile \
install \
nixpkgs/a765beccb52f30a30fee313fbae483693ffe200d#podman \
nixpkgs#minikube \
nixpkgs#cri-o

sudo apt-get update \
&& sudo apt-get install -y uidmap

sudo \
--preserve-env \
su \
-c \
"echo $USER ALL=\(ALL\) NOPASSWD:SETENV: $(readlink $(which podman)) >> /etc/sudoers"

sudo ln -fsv /home/ubuntu/.nix-profile/bin/podman /usr/bin/podman
sudo ln -fsv "$(nix eval --raw nixpkgs#cri-o)"/bin/crio /usr/lib/crio
```

podman network create

```bash
echo 'Start cgroup v2 instalation...' \
&& sudo mkdir -p /etc/systemd/system/user@.service.d \
&& sudo sh -c "echo '[Service]' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo sh -c "echo 'Delegate=yes' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo \
sed \
--in-place \
's/^GRUB_CMDLINE_LINUX="/&cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1 cgroup_no_v1=all/' \
/etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg \
&& echo 'End cgroup v2 instalation...'
```

```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
busybox \
sh \
-c \
"ping -W10 -c1 google.com | grep -e '0% packet loss'"
```

```bash
minikube start --driver=podman --container-runtime=cri-o
```


#### In podman 3.4?
podman pod create --userns=keep-id --name dan1 \
&& podman run --pod dan1 fedora id


### Volume mount

```bash
kill -9 $(pidof qemu-system-x86_64) || true \
&& result/refresh || nix build .#qemu.vm \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "\$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"\$SHA256"/get-nix.sh | sh \
&& . "\$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."\$(ps -ocomm= -q \$\$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="\$(readlink -f \$(which nix))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall \$OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version
COMMANDS
}
```

```bash
export VOLUME_MOUNT_PATH=/home/ubuntu/code

cat <<WRAP >> "$HOME"/.bashrc
sudo mount -t 9p \
-o trans=virtio,access=any,cache=none,version=9p2000.L,cache=none,msize=262144,rw \
hostshare \
"$VOLUME_MOUNT_PATH"

cd "$VOLUME_MOUNT_PATH"
WRAP

test -d "$VOLUME_MOUNT_PATH" || sudo mkdir -p "$VOLUME_MOUNT_PATH"

sudo mount -t 9p \
-o trans=virtio,access=any,cache=none,version=9p2000.L,cache=none,msize=262144,rw \
hostshare "$VOLUME_MOUNT_PATH"

OLD_UID=$(getent passwd "$(id -u)" | cut -f3 -d:)
NEW_UID=$(stat -c "%u" "$VOLUME_MOUNT_PATH")

OLD_GID=$(getent group "$(id -g)" | cut -f3 -d:)
NEW_GID=$(stat -c "%g" "$VOLUME_MOUNT_PATH")


if [ "$OLD_UID" != "$NEW_UID" ]; then
    echo "Changing UID of $(id) from $OLD_UID to $NEW_UID"
    #sudo usermod -u "$NEW_UID" -o $(id -un $(id -u))
    sudo find / -xdev -uid "$OLD_UID" -exec chown -h "$NEW_UID" {} \;
fi

if [ "$OLD_GID" != "$NEW_GID" ]; then
    echo "Changing GID of $(id) from $OLD_GID to $NEW_GID"
    #sudo groupmod -g "$NEW_GID" -o $(id -gn $(id -u))
    sudo find / -xdev -group "$OLD_GID" -exec chgrp -h "$NEW_GID" {} \;
fi

sudo su -c "sed -i -e \"s/^\(ubuntu:[^:]\):[0-9]*:[0-9]*:/\1:${NEW_UID}:${NEW_GID}:/\" /etc/passwd && sed -i \"/^ubuntu/s/:[0-9]*:/:${NEW_GID}:/g\" /etc/group && reboot"

unset VOLUME_MOUNT_PATH
```

```bash
nix \
develop \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
create-nix-flake-backup \
&& prepares-volume \
&& ssh-vm
```


###

ssh-vm-ubuntu-volume() {
  test -d result \
  || nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
  && ${pkgs.procps}/bin/pidof qemu-system-x86_64 \
  || (result/run-vm-kvm < /dev/null &) \
  && ssh-vm
}

ssh-vm-ubuntu-volume-dev() {
  ${pkgs.procps}/bin/pidof qemu-system-x86_64 \
  || test -d result \
  || nix build .#qemu.vm \
  && (result/run-vm-kvm < /dev/null &)

  ${pkgs.procps}/bin/pidof qemu-system-x86_64 \
  || (result/run-vm-kvm < /dev/null &) \
  && result/ssh-vm
}


`findmnt -rno SOURCE,TARGET "$1"`
https://serverfault.com/a/901858



```bash
nix \
develop
```

```bash
vm-kill; \
prepares-volume \
&& ssh-vm
```


```bash
nix \
develop \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev
```


```bash
nix \
develop \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
vm-kill; \
prepares-volume \
&& ssh-vm
```

```bash
nix \
develop \
github:ES-Nix/nix-qemu-kvm/dev \
--command \
ssh-vm; prepares-volume && ssh-vm
```


```bash
rm -f result \
&& nix store gc --verbose \
&& nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh --command bash -c 'vm-kill; ssh-vm-dev'
```

```bash
rm -fv result *.qcow2*; \
nix store gc --verbose \
&& nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
--command bash -c 'result/prepares-volume && result/ssh-vm'
```


```bash
rm -fv result *.qcow2*; \
nix store gc --verbose \
&& nix develop --refresh --command bash -c 'ssh-vm-dev'
```

```bash
rm -fv result *.qcow2*; \
nix store gc --verbose \
&& nix \
develop \
--refresh \
--command \
bash \
-c \
'vm-kill; prepares-volume && ssh-vm-dev'
```

```bash
test -f result || nix build .# \
&& nix \
develop \
.# \
--refresh \
--command \
bash \
-c \
'vm-kill; prepares-volume && ssh-vm-dev'
```



### Enable KVM, cgroup2 and more

TODO: explain what is it all, which error would be faced if it is not done...
```bash
echo 'Start kvm stuff...' \
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
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...' \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& sudo reboot
```

### 


```bash
rm -fv result *.qcow2*; \
nix store gc --verbose \
&& nix store optimise --verbose \
&& nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev \
--command bash -c 'vm-kill; run-vm-kvm && prepares-volume && ssh-vm'
```

Do some thing inside the VM, for example, install nix and:

```bash
vm-kill; backup-current-state default \
&& vm-kill; reset-to-backup && qemu-img resize disk.qcow2 +16G && ssh-vm
```

Useful to play with a snapshot:  
```bash
nix \
develop \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev
```

Do some stuff, and backup the state:
```bash
backup-current-state <backup-name>
```

Resetting to a backup state:
```bash
vm-kill; reset-to-backup <backup-name> && ssh-vm
```

It kills the vm, restores a backup, resize the disk.qcow2 and ssh into the VM:
```bash
vm-kill; reset-to-backup \
&& qemu-img resize disk.qcow2 +18G \
&& ssh-vm
```

#### Troubleshooting


```bash
ps -fp $(pidof qemu-system-x86_64) | tr ' ' '\n'

tr '\0' '\n' < /proc/$(pidof qemu-system-x86_64)/cmdline
tr '\0' '\n' < /proc/$(pidof qemu-system-x86_64)/environ


# lsof | { head -1 ; rg disk.qcow2 ; } 
```
From: https://stackoverflow.com/questions/821837/how-to-get-the-command-line-args-passed-to-a-running-process-on-unix-linux-syste

```bash
qemu-img info disk.qcow2
qemu-img resize disk.qcow2 +16G
qemu-img info disk.qcow2
```
Adapted from: 
https://maunium.net/blog/resizing-qcow2-images/ 
and https://serverfault.com/questions/329287/free-up-not-used-space-on-a-qcow2-image-file-on-kvm-qemu
and https://serverfault.com/a/797350

https://stackoverflow.com/questions/29124150/how-to-resize-the-qcow2-image-without-impact-the-application

#### In an OCI image running with podman


```bash
podman \
run \
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
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=0755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf

echo 'Started'

nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev \
--command bash -c 'vm-kill; run-vm-kvm && prepares-volume && ssh-vm'
COMMANDS
```

### The kind



```bash
echo 'Start minikube stuff...' \
&& curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
&& chmod -v 0755 minikube \
&& sudo mv -v minikube /usr/local/bin \
&& echo 'End minikube stuff...' \
&& echo 'Start kubectl stuff...' \
&& echo 'https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux' \
&& curl -LO https://dl.k8s.io/release/v1.21.2/bin/linux/amd64/kubectl \
&& curl -LO "https://dl.k8s.io/v1.21.2/bin/linux/amd64/kubectl.sha256" \
&& echo "$(<kubectl.sha256) kubectl" | sha256sum --check \
&& chmod -v +x kubectl \
&& test -d "$HOME/.local/bin" || mkdir -p "$HOME"/.local/bin \
&& grep -e 'export PATH=~/.local/bin:"$PATH"' -i ~/.bashrc || echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc \
&& mv ./kubectl ~/.local/bin/kubectl \
&& echo 'End kubectl stuff...' \
&& echo 'Start docker instalation...' \
&& curl -fsSL https://get.docker.com | sudo sh \
&& getent group docker || sudo groupadd docker \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& echo 'End docker instalation!' \
&& sudo apt-get install -y golang-go \
&& sudo reboot
```


```bash
echo 'Start docker instalation...' \
&& curl -fsSL https://get.docker.com | sudo sh \
&& getent group docker || sudo groupadd docker \
&& sudo usermod --append --groups docker "$USER" \
&& docker --version \
&& echo 'End docker installation!'
```


```bash
sudo groupadd docker; \
sudo usermod --append --groups docker "$USER" \
&& sudo reboot
```

```bash
nix \
profile \
install \
nixpkgs#docker \
nixpkgs#kind \
nixpkgs#kubectl \
&& sudo cp "$(nix eval --raw nixpkgs#docker)"/etc/systemd/system/{docker.service,docker.socket} /etc/systemd/system/ \
&& sudo systemctl enable --now docker
```
Refs.: 
- https://github.com/NixOS/nixpkgs/issues/70407
- https://github.com/moby/moby/tree/e9ab1d425638af916b84d6e0f7f87ef6fa6e6ca9/contrib/init/systemd


```bash
docker \
run \
--rm \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'apk add --no-cache curl'
```

```bash
docker \
run \
--interactive=true \
--tty=true \
--rm=true \
--user='0' \
--volume="$(pwd)":/code:rw \
--workdir=/code \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'touch abc123.txt'
```


```bash
time kind create cluster --name testcluster
```

```bash
kubeclt get nodes
kubectl cluster-info
kubectl cluster-info dump
```



```bash
vm-kill; \
   run-vm-kvm \
&& prepares-volume \
&& install-nix \
&& ssh-vm
```

```bash
vm-kill; \
   backup-current-state \
&& qemu-img resize disk.qcow2 +16G \
&& ssh-vm
```

```bash
vm-kill; \
   run-vm-kvm \
&& prepares-volume \
&& vm-kill; \
   install-nix \
&& backup-current-state default \
&& vm-kill; \
   sleep 1 \
&& qemu-img resize disk.qcow2 +16G \
&& ssh-vm
```


```bash
echo '.' \
&& { cat << EOF > ~/script.sh
#!/bin/sh

# set -ex


for commit in $(git rev-list --all)
do

    nix build github:arianvp/webauthn-oidc/"$commit" --no-link

    retexit_code=$?
    if [ $retexit_code -ne 0 ]; then
        echo $commit >> log_error.out  
    else
        echo $commit >> log.out
    fi

    nix store gc --verbose \
    && nix store optimise --verbose
done
EOF 
} && chmod +x ~/script.sh \
&& ./script.sh
```

```bash
cat log_error.out | wc -l
cat log.out | wc -l
```



##### Did not work

```bash
nix build nixpkgs#docker
ls -al result/etc/systemd/system/
```

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo cp result/etc/systemd/system/{docker.service,docker.socket} /etc/systemd/system/docker.service.d/
```


```bash
nix profile install nixpkgs#kind nixpkgs#kubectl
time kind create cluster
```

###


```bash
go version
docker --version
```


```bash
nix \
profile \
install \
nixpkgs#kind \
nixpkgs#kubectl \
nixpkgs#cni \
nixpkgs#cni-plugins \
nixpkgs#conntrack-tools \
nixpkgs#cri-o \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version \
&& echo \
&& echo 'Start kvm stuff...' \
&& getent group kvm || sudo groupadd kvm \
&& sudo usermod --append --groups kvm "$USER" \
&& echo 'End kvm stuff!' \
&& echo \
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
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...'  \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo \
echo 'Start cni and crio stuff...' \
&& sudo mkdir -pv /usr/lib/cni \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/bandwidth /usr/lib/cni/bandwidth \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/bridge /usr/lib/cni/bridge \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/dhcp /usr/lib/cni/dhcp \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/firewall /usr/lib/cni/firewall \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/host-device /usr/lib/cni/host-device \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/host-local /usr/lib/cni/host-local \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/ipvlan /usr/lib/cni/ipvlan \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/loopback /usr/lib/cni/loopback \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/macvlan /usr/lib/cni/macvlan \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/portmap /usr/lib/cni/portmap \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/ptp /usr/lib/cni/ptp \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/sbr /usr/lib/cni/sbr \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/static /usr/lib/cni/static \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/tuning /usr/lib/cni/tuning \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/vlan /usr/lib/cni/vlan \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/vrf /usr/lib/cni/vrf \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cri-o)"/bin/crio /usr/lib/crio \
&& echo 'End cni and crio stuff...' \
&& sudo reboot
```


```bash
cd ~ \
&& { cat << EOF >  ~/kind-example-config.yaml
# From: https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/content/docs/user/kind-example-config.yaml
# this config file contains all config fields with comments
# NOTE: this is not a particularly useful config file
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# patch the generated kubeadm config with some extra settings
kubeadmConfigPatches:
- |
  apiVersion: kubelet.config.k8s.io/v1beta1
  kind: KubeletConfiguration
  evictionHard:
    nodefs.available: "0%"
# patch it further using a JSON 6902 patch
kubeadmConfigPatchesJSON6902:
- group: kubeadm.k8s.io
  version: v1beta2
  kind: ClusterConfiguration
  patch: |
    - op: add
      path: /apiServer/certSANs/-
      value: my-hostname
# 1 control plane node and 3 workers
nodes:
# the control plane node config
- role: control-plane
# the three workers
- role: worker
- role: worker
- role: worker
EOF
} && KIND_EXPERIMENTAL_PROVIDER=podman time kind create cluster 
```

```bash
time kind create cluster --kubeconfig ~/kind-example-config.yaml
```

```bash
cat << EOF > config.yaml

```

KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster -v9


```bash
cat << EOF | KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- extraMounts:
  - hostPath: /dev/mapper
    containerPath: /dev/mapper
EOF
```

```bash
tr '\0' '\n' < /proc/1351/cmdline
ps -eF --sort=-rss
sudo strace -v -s 4096 -f -c -p $(pidof kind)
tr '\0' '\n' < /proc/$(echo $(pidof podman) | cut -d' ' -f1)/cmdline
strace -v -s 4096 -f -o trace.txt id
sudo strace -v -s 4096 -f -o trace.txt sudo id
```

Refs.:
- https://stackoverflow.com/a/57696584
- https://unix.stackexchange.com/a/83808


```bash
podman \
run \
--hostname ffoo-control-plane \
--name ffoo-control-plane \
--label io.x-k8s.kind.role=control-plane \
--privileged \
--tmpfs /tmp \
--tmpfs /run \
--volume 7e7df0f822ef35f9d5f9e10f27e5a110d19f458e3cb20ad9ecd4fb9b5708686e:/var:suid,exec,dev \
--volume /lib/modules:/lib/modules:ro \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
--detach \
--tty \
--net kind \
--label io.x-k8s.kind.cluster=ffoo \
-e container=podman \
--publish=127.0.0.1:34163:6443/tcp \
-e KUBECONFIG=/etc/kubernetes/admin.conf \
kindest/node@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6
```

systemctl status sys-kernel-tracing.mount


podman run -it --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw --rm 32b8b755dee8 bash
docker run -it --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw --rm kindest/node@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6
docker pull kindest/node@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6



docker run --rm -v /var/run/docker.sock:/var/run/docker.sock nexdrew/rekcod

```bash
docker \
run \
--name kind-control-plane \
--privileged \
--runtime runc \
-v /lib/modules:/lib/modules:ro \
-p 127.0.0.1:40169:6443/tcp \
--net kind \
--security-opt 'seccomp=unconfined' \
--security-opt 'apparmor=unconfined' \
--security-opt 'label=disable' \
-h kind-control-plane \
--expose 6443/tcp \
-l io.x-k8s.kind.cluster='kind' \
-l io.x-k8s.kind.role='control-plane' \
-e 'KUBECONFIG=/etc/kubernetes/admin.conf' \
-e 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
-e 'container=docker' \
-d \
-t \
--entrypoint="/usr/local/bin/entrypoint /sbin/init" \
--rm \
kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6
```

```bash
docker \
inspect \
--format "$(curl -s https://gist.githubusercontent.com/efrecon/8ce9c75d518b6eb863f667442d7bc679/raw/run.tpl)" \
ab86810beec3
```

Refs.:
- https://gist.github.com/efrecon/8ce9c75d518b6eb863f667442d7bc679#gistcomment-3582870


```bash
docker \
  run \
  --name "/kind-control-plane" \
  --privileged \
  --runtime "runc" \
  --volume "/lib/modules:/lib/modules:ro" \
  --log-driver "json-file" \
  --restart "on-failure:1" \
  --publish "127.0.0.1:46123:6443/tcp" \
  --network "kind" \
  --network-alias "ab86810beec3" \
  --network-alias "kind-control-plane" \
  --hostname "kind-control-plane" \
  --expose "6443/tcp" \
  --env "KUBECONFIG=/etc/kubernetes/admin.conf" \
  --env "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  --env "container=docker" \
  --label "io.x-k8s.kind.cluster"="kind" \
  --label "io.x-k8s.kind.role"="control-plane" \
  --detach \
  --tty \
  "kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6"
```


```bash
podman \
  run \
  --name "kind-control-plane" \
  --privileged \
  --runtime "runc" \
  --volume "/lib/modules:/lib/modules:ro" \
  --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
  --log-driver "json-file" \
  --restart "on-failure:1" \
  --publish "127.0.0.1:46123:6443/tcp" \
  --network "kind" \
  --network-alias "ab86810beec3" \
  --network-alias "kind-control-plane" \
  --hostname "kind-control-plane" \
  --expose "6443/tcp" \
  --env "KUBECONFIG=/etc/kubernetes/admin.conf" \
  --env "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  --env "container=podman" \
  --label "io.x-k8s.kind.cluster"="kind" \
  --label "io.x-k8s.kind.role"="control-plane" \
  --detach \
  --tty \
  kindest/node:v1.21.1
```


podman network create kind




podman \
  run \
  --volume "/lib/modules:/lib/modules:ro" \
  --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
  -i \
  --tty \
  --rm \
  --privileged \
  kindest/node:v1.21.1




```bash
nix \
profile \
install \
nixpkgs#cni \
nixpkgs#cni-plugins \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version \
&& echo \
&& echo 'Start cni stuff...' \
&& sudo mkdir -pv /usr/lib/cni \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/bandwidth /usr/lib/cni/bandwidth \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/bridge /usr/lib/cni/bridge \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/dhcp /usr/lib/cni/dhcp \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/firewall /usr/lib/cni/firewall \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/host-device /usr/lib/cni/host-device \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/host-local /usr/lib/cni/host-local \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/ipvlan /usr/lib/cni/ipvlan \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/loopback /usr/lib/cni/loopback \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/macvlan /usr/lib/cni/macvlan \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/portmap /usr/lib/cni/portmap \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/ptp /usr/lib/cni/ptp \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/sbr /usr/lib/cni/sbr \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/static /usr/lib/cni/static \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/tuning /usr/lib/cni/tuning \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/vlan /usr/lib/cni/vlan \
&& sudo ln -fsv "$(nix eval --raw nixpkgs#cni-plugins)"/bin/vrf /usr/lib/cni/vrf \
&& echo 'End cni stuff...' 


echo 'Start bypass sudo podman stuff...' \
&& echo 'Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:'"$(nix eval --raw github:ES-Nix/podman-rootless/from-nixpkgs)/bin" | sudo tee -a /etc/sudoers.d/"$USER" \
&& echo 'End bypass sudo podman stuff...'

sudo podman --version
sudo podman network create podman

sudo \
podman \
run \
--entrypoint=/bin/bash \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--volume=/dev/mapper:/dev/mapper \
--volume=/lib/modules:/lib/modules:ro \
quay.io/podman/stable:v3.4.1
```

Refs:
- https://unix.stackexchange.com/questions/83191/how-to-make-sudo-preserve-path/151188#151188
- https://stackoverflow.com/a/8447577

```bash
podman pull docker.io/kindest/node:v1.21.1
podman images
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
export KIND_EXPERIMENTAL_PROVIDER=podman
sed -i '/^utsns/d' /etc/containers/containers.conf
./kind create cluster --retain --image=docker.io/kindest/node:v1.21.1
```

```bash
export USER=podman
echo "$USER"' ALL=(ALL) NOPASSWD:SETENV: ALL' | sudo tee -a /etc/sudoers.d/"$USER"

sudo chmod 0700 /home/"$USER"
sudo chown "$USER": -R /home/"$USER"

echo "$USER"':100000:65536' | sudo tee -a /etc/subuid \
&& echo "$USER"':100000:65536' | sudo tee -a /etc/subgid \
&& su podman
```

```bash
sudo \
podman \
run \
--entrypoint=/bin/bash \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--volume=/dev/mapper:/dev/mapper:rw \
--volume=/lib/modules:/lib/modules:ro \
quay.io/podman/stable:v3.4.1
```

```bash
sudo \
podman \
run \
--entrypoint=/bin/bash \
--interactive=true \
--privileged=true \
--rm=true \
--tty=false \
--volume=/dev/mapper:/dev/mapper:rw \
--volume=/lib/modules:/lib/modules:ro \
quay.io/podman/stable:v3.4.1 \
<<COMMANDS
podman pull docker.io/kindest/node:v1.21.1
podman images
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
export KIND_EXPERIMENTAL_PROVIDER=podman
sed -i '/^utsns/d' /etc/containers/containers.conf
./kind create cluster --retain --image=docker.io/kindest/node:v1.21.1
COMMANDS
```


podman info | grep cgroupVersion


```bash
sudo \
podman \
run \
--entrypoint=/bin/bash \
--interactive=true \
--privileged=false \
--rm=true \
--tty=true \
--volume="$(pwd)":/code:rw \
--volume=/dev/mapper:/dev/mapper:rw \
--volume=/dev/fuse:/dev/fuse:rw \
--volume=/lib/modules:/lib/modules:ro \
quay.io/podman/stable:v3.4.1
```

--device=/dev/fuse \

```bash
cd
podman pull docker.io/kindest/node:v1.21.1
podman images
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
export KIND_EXPERIMENTAL_PROVIDER=podman
sed -i '/^utsns/d' /etc/containers/containers.conf
./kind create cluster --retain --image=docker.io/kindest/node:v1.21.1
```
podman save > /code/image.tar.gz docker.io/kindest/node:v1.21.1
podman load < /code/image.tar.gz


podman \
run \
--log-level=debug \
--hostname kind-control-plane \
--name kind-control-plane \
--label io.x-k8s.kind.role=control-plane \
--privileged \
--tmpfs /tmp \
--tmpfs /run \
--volume c28e813d751843faa157d7e24017b9e78cbb4e9b02c1391c545319cd0963e394:/var:suid,exec,dev \
--volume /lib/modules:/lib/modules:ro \
--detach \
--tty \
--net kind \
--label io.x-k8s.kind.cluster=kind \
-e container=podman \
--publish=127.0.0.1:36745:6443/tcp \
-e KUBECONFIG=/etc/kubernetes/admin.conf \
--rm \
docker.io/kindest/node:v1.21.1

sudo dnf install -y go

sudo chown -R $(id -u):$(id -g) /dev


podman \
run \
--annotation run.oci.keep_original_groups=1 \
--entrypoint=/bin/bash \
--interactive=true \
--privileged=false \
--rm=true \
--tty=true \
--userns=keep-id \
--volume="$(pwd)":/code:rw \
--volume=/dev/mapper:/dev/mapper:rw \
--volume=/lib/modules:/lib/modules:ro \
quay.io/podman/stable:v3.4.1


podman \
run \
--entrypoint=/bin/bash \
--interactive=true \
--privileged=false \
--rm=true \
--tty=true \
--volume="$(pwd)":/code:rw \
--volume=/dev/mapper:/dev/mapper:rw \
--volume=/lib/modules:/lib/modules:ro \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
quay.io/podman/stable:v3.4.1


### KinP with rootfull podman, all from nixpkgs


```bash
nix \
profile \
install \
nixpkgs#cni \
nixpkgs#cni-plugins \
nixpkgs#kind \
nixpkgs#kubectl \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version \
&& echo \
&& echo 'Start cni stuff...' \
&& test -d /etc/containers || sudo mkdir -pv /etc/containers \
&& { sudo tee /etc/containers/containers.conf > /dev/null <<'EOF'
[engine]
events_logger = "file"
cgroup_manager = "cgroupfs"

[network]
cni_plugin_dirs = [
  "/usr/local/libexec/cni",
  "/usr/libexec/cni",
  "/usr/local/lib/cni",
  "/usr/lib/cni",
  "/opt/cni/bin",
]
EOF
} && NIX_CNI_PLUGINS_PATH="$(nix eval --raw nixpkgs#cni-plugins)"/bin \
&& sudo sed -i '\="/opt/cni/bin",=a    "'${NIX_CNI_PLUGINS_PATH}'",' /etc/containers/containers.conf \
&& echo 'End cni stuff...'

echo 'Start bypass sudo podman stuff...' \
&& PODMAN_NIX_PATH="$(nix eval --raw github:ES-Nix/podman-rootless/from-nixpkgs)/bin" \
&& KIND_NIX_PATH="$(nix eval --raw nixpkgs#kind)/bin" \
&& KUBECTL_NIX_PATH="$(nix eval --raw nixpkgs#kubectl)/bin" \
&& echo 'Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:'"$PODMAN_NIX_PATH":"$KIND_NIX_PATH":"$KUBECTL_NIX_PATH" | sudo tee -a /etc/sudoers.d/"$USER" \
&& echo 'End bypass sudo podman stuff...'

sudo podman --version
sudo kubectl version
sudo kind --version
sudo podman network exists podman || sudo podman network create podman

sudo podman pull docker.io/kindest/node:v1.21.1
sudo podman images
```
Refs.:
- https://stackoverflow.com/questions/1797906/delete-using-a-different-delimiter-with-sed#comment116336487_1797967


```bash
sudo kind create cluster --retain --image=docker.io/kindest/node:v1.21.1
```


```bash
sudo kubectl cluster-info --context kind-kind
sudo kubectl get pods -A
```


```bash
sudo kubectl apply -f https://k8s.io/examples/application/shell-demo.yaml

sudo kubectl get pod shell-demo

sudo kubectl exec --stdin --tty shell-demo -- /bin/bash -c 'ls -al /'

sudo kubectl delete pod shell-demo
```


```bash
sudo \
apt-get \
remove \
--purge \
--auto-remove \
--allow-remove-essential \
-y \
systemd

systemd
jornalctl
```



###




sudo \
podman \
run \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--privileged=true \
--tty=true \
--rm=true \
--user=0 \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--volume=/lib/modules:/lib/modules:ro \
--volume=/dev/mapper:/dev/mapper:rw \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
docker.io/library/fedora:36

dnf install -y podman

podman \
run \
--rm \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'apk add --no-cache curl'


```bash
podman \
run \
--interactive=true \
--memory-reservation=200m \
--memory=300m \
--memory-swap=300m \
--rm=true \
--tty=true \
docker.io/library/alpine:3.14.2 \
echo \
'Hi!'
```

podman \
stats \
--cgroup-manager=systemd


podman \
stats \
--cgroup-manager=cgroupfs

```bash
podman \
run \
--events-backend="file" \
--storage-driver="vfs" \
--cgroups=disabled \
--log-level=error \
--interactive=true \
--network=host \
--tty=true \
docker.io/library/alpine:3.14.2 \
sh \
-c 'apk add --no-cache curl && echo PinP'
```



```bash
podman pull docker.io/kindest/node:v1.21.1
podman images
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
export KIND_EXPERIMENTAL_PROVIDER=podman
./kind create cluster --retain --image=docker.io/kindest/node:v1.21.1
```

sed -i '/^utsns/d' /etc/containers/containers.conf

```bash
echo 'Start cgroup v1 instalation...' \
&& sudo rm -fr /etc/systemd/system/user@.service.d \
&& sudo \
sed \
-i \
's/^GRUB_CMDLINE_LINUX=".*"/GRUB_CMDLINE_LINUX=""/' \
/etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg \
&& echo 'End cgroup v1 instalation...' \
&& sudo reboot
```

cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=0

```bash
echo 'Start cgroup v2 instalation...' \
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
&& sudo reboot
```

```bash
sudo kind delete cluster
```


```bash
sudo kind create cluster --retain --image=docker.io/kindest/node:v1.21.1
```


```bash
sudo apt-get update
sudo apt-get install -y openssh-server wget

sudo sed -i 's/#   Port .*/    Port 29980/' /etc/ssh/ssh_config

sudo systemctl restart ssh


wget https://github.com/PedroRegisPOAR.keys

test -d ~/.ssh || mkdir -pv ~/.ssh

cat PedroRegisPOAR.keys >> ~/.ssh/authorized_keys

rm -f PedroRegisPOAR.keys
```

```bash
ssh ubuntu@127.0.0.1 -p 10022
```


```bash
ssh root@127.0.0.1 -p 10022
```


### microk8s from snap


```bash
sudo snap install microk8s --classic
microk8s --version
```


### Podman rootless and systemd


[How to run systemd in a container](https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container#)

`STOPSIGNAL SIGRTMIN+3` from https://github.com/kubernetes-sigs/kind/blob/ecd604e78108007b672e42a5dc6244a150e03950/images/base/Dockerfile#L214

In:
```bash
nix build --refresh github:ES-Nix/nix-qemu-kvm/dev \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev

backup-current-state default
vm-kill; reset-to-backup && qemu-img resize disk.qcow2 +16G && ssh-vm
```

TODO: it should be a facade, hide all these complexities in a simpler command, 
podman flake should know how to install itself.
```bash
nix \
profile \
install \
nixpkgs#cni \
nixpkgs#cni-plugins \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version \
&& echo \
&& echo 'Start cni stuff...' \
&& test -d /etc/containers || sudo mkdir /etc/containers \
&& { sudo tee /etc/containers/containers.conf > /dev/null <<'EOF'
[engine]
events_logger = "file"
cgroup_manager = "systemd"

[network]
cni_plugin_dirs = [
  "/usr/local/libexec/cni",
  "/usr/libexec/cni",
  "/usr/local/lib/cni",
  "/usr/lib/cni",
  "/opt/cni/bin",
]
EOF
} && NIX_CNI_PLUGINS_PATH="$(nix eval --raw nixpkgs#cni-plugins)"/bin \
&& sudo sed -i '\="/opt/cni/bin",=a    "'${NIX_CNI_PLUGINS_PATH}'",' /etc/containers/containers.conf \
&& echo 'End cni stuff...'

echo 'Start bypass sudo podman stuff...' \
&& PODMAN_NIX_PATH="$(nix eval --raw github:ES-Nix/podman-rootless/from-nixpkgs)/bin" \
&& echo 'Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:'"$PODMAN_NIX_PATH" | sudo tee -a /etc/sudoers.d/"$USER" \
&& echo 'End bypass sudo podman stuff...'

sudo podman --version
sudo podman network exists podman || sudo podman network create podman

sudo podman images
```
Refs.:
- https://stackoverflow.com/questions/1797906/delete-using-a-different-delimiter-with-sed#comment116336487_1797967


```bash
echo 'Start cgroup v2 instalation...' \
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
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...' \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& sudo reboot
```


```bash
cat > Containerfile << EOF
FROM docker.io/library/fedora:34

RUN dnf -y install httpd; dnf clean all; systemctl enable httpd

EXPOSE 80

CMD [ "/sbin/init" ]
EOF

sudo \
podman \
build \
--file Containerfile \
--tag systemd \
.

sudo podman images

sudo \
podman \
run \
--interactive=true \
--name=play-systemd \
--publish=80:80 \
--tty=true \
--tty=true \
localhost/systemd
```

```bash
sudo \
podman \
exec \
--interactive=true \
--tty=true \
play-systemd \
bash \
-c \
"uname -a \
&& echo \
&& dnf --version"
```


```bash
curl localhost
```


#### Rootless?

```bash
sudo sysctl net.ipv4.ip_unprivileged_port_start=80
```

```bash
echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee -a /etc/sysctl.conf
```
Refs.: https://github.com/containers/podman/issues/7866#issuecomment-702903624

```bash
cat > Containerfile << EOF
FROM docker.io/library/fedora:34

RUN dnf -y install httpd; dnf clean all; systemctl enable httpd

EXPOSE 80

CMD [ "/sbin/init" ]
EOF

podman \
build \
--file Containerfile \
--tag systemd \
.

podman images

podman \
run \
--interactive=true \
--name=play-systemd \
--publish=80:80 \
--rm=true \
--tty=true \
localhost/systemd
```

```bash
podman \
exec \
--interactive=true \
--tty=true \
play-systemd \
bash \
-c \
"uname -a \
&& echo \
&& dnf --version"
```


```bash
 cat > Containerfile << _EOF
FROM registry.fedoraproject.org/fedora:32
RUN dnf -y install systemd httpd
RUN systemctl enable httpd
EXPOSE 80
CMD [ "/sbin/init" ]
_EOF

podman \
build \
--file=Containerfile \
--tag=httpd . \
&& podman \
run \
--interactive=true \
--name=httpd \
--rm=true \
--tty=true \
localhost/httpd
```

TODO: broken, seems like all images 35, 36 and latest are broken 
      https://github.com/fedora-cloud/docker-brew-fedora/issues/100
```bash
podman \
run \
--interactive=true \
--name=test-bug \
--rm=true \
--tty=true \
registry.fedoraproject.org/fedora:36 \
bash \
-c \
"yum update -y"
```


#### OCI Ubuntu 21.10 ran with podman to run systemd 

```bash
podman \
run \
--interactive=true \
--rm=true \
--tty=true \
docker.io/library/ubuntu:21.10 \
bash 
```


```bash
cat > Containerfile << EOF
FROM docker.io/library/ubuntu:21.10
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends -y \
        lighttpd \
        systemd \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*
EXPOSE 80
CMD [ "/usr/lib/systemd/systemd" ]
EOF

podman \
build \
--file=Containerfile \
--tag=httpd . \
&& podman \
run \
--interactive=true \
--name=httpd \
--rm=true \
--tty=true \
localhost/httpd
```
Refs.: https://unix.stackexchange.com/a/499585


```bash
podman \
exec \
--interactive=true \
--tty=true \
httpd \
bash \
-c \
"uname -a \
&& echo \
&& systemctl --version \
&& systemctl status | cat"
```


#### OCI Ubuntu 21.10 ran with podman to run systemd 

```bash
podman \
run \
--interactive=true \
--rm=true \
--tty=true \
docker.io/library/ubuntu:21.10 \
bash 
```


```bash
cat > Containerfile << EOF
FROM docker.io/library/ubuntu:21.10
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends -y \
        lighttpd \
        systemd \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*
EXPOSE 80
CMD [ "/usr/lib/systemd/systemd" ]
EOF

podman \
build \
--file=Containerfile \
--tag=httpd . \
&& podman \
run \
--interactive=true \
--name=httpd \
--rm=true \
--tty=true \
localhost/httpd
```
Refs.: https://unix.stackexchange.com/a/499585


```bash
podman \
exec \
--interactive=true \
--tty=true \
httpd \
bash \
-c \
"uname -a \
&& echo \
&& systemctl --version \
&& systemctl status | cat"
```


```bash
podman \
run \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=true \
--tty=false \
--rm=true \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir -p -m 0755 -v ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf

COMMANDS
```


```bash
cat > Containerfile << EOF
FROM docker.nix-community.org/nixpkgs/nix-flakes


ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix profile install github:NixOS/nixpkgs/nixos-21.11#systemd github:NixOS/nixpkgs/nixos-21.11#apacheHttpd \
    && nix store gc -v

# RUN echo "$(nix eval --raw github:NixOS/nixpkgs/nixos-21.11#systemd)"
ARG SYSTEMD_NIX_PATH=/nix/store/q0881awy50g4srnnwasci37y2jk5sf99-systemd-249.5
#ENV SYSTEMD_NIX_PATH=/nix/store/q0881awy50g4srnnwasci37y2jk5sf99-systemd-249.5

RUN echo "$SYSTEMD_NIX_PATH"
RUN cp -rv /nix/store/q0881awy50g4srnnwasci37y2jk5sf99-systemd-249.5/share /usr/share
RUN cp -rv /nix/store/q0881awy50g4srnnwasci37y2jk5sf99-systemd-249.5/lib /usr/lib

EXPOSE 80
CMD [ "/nix/store/q0881awy50g4srnnwasci37y2jk5sf99-systemd-249.5/bin/init" ]
EOF

podman \
build \
--file=Containerfile \
--tag=nix-httpd .

podman \
run \
--interactive=true \
--name=nix-httpd-container \
--privileged=true \
--rm=true \
--tty=true \
localhost/nix-httpd
```


podman \
run \
--entrypoint=/bin/bash \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
localhost/nix-httpd


podman \
run \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
docker.nix-community.org/nixpkgs/nix-flakes


Creating a diff in the filesystem's OCI image:
```bash
CONTAINER=cdiff

podman \
run \
--name="$CONTAINER" \
--interactive=true \
--tty=false \
--rm=false \
--user='0' \
docker.io/library/ubuntu:21.10 \
bash \
<< COMMANDS
    apt-get update \
    && apt-get install -y --no-install-recommends -y \
        systemd \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*
COMMANDS
                     
# Ok, maybe a really hard, not yet seem, bug is hidden here!
# Could it happend to when the podman diff is invoked 
# NOT ALL stuff being done has finished?
# Must it send a SIGSTOP (is it correct spelled?) before podman diff to make sure it can not race condition?  
                                                                                                                                            
rm -f oci_diff.txt                                                                                                                                               
podman diff "$CONTAINER" > oci_diff.txt                                                                                                                          
```


```bash
cat << EOF > "$HOME"/hello-world.sh
#!/bin/bash
while true; do echo 'Hello world: '$(date +"%Y/%m/%d %T.%N"); sleep $(shuf -i 1-3 -n 1); done
EOF

chmod a+x "$HOME"/hello-world.sh


cat << EOF > /etc/systemd/system/hello-word.service
[Unit]
Description=Hello World Service Example
After=systend-user-sessions.service

[Service]
Type=simple
ExecStart=$HOME/hello-world.sh
EOF

systemctl start hello-world.service
```


```bash
systemctl status hello-world.service

journalctl -u -e hello-world
```


###


wget https://cloud-images.ubuntu.com/minimal/releases/focal/release-20210130/ubuntu-20.04-minimal-cloudimg-amd64.img

```bash
qemu-kvm \
-enable-kvm \
-cpu Haswell-noTSX-IBRS,vmx=on \
-cpu host
-m 1024 \
-name u20 \
-drive file=ubuntu-20.04-minimal-cloudimg-amd64.img,if=virtio \
-fsdev local,security_model=passthrough,id=fsdev0,path=/tmp \
-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
```


wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release-20220506/ubuntu-22.04-minimal-cloudimg-amd64.img

```bash
qemu-kvm \
-enable-kvm \
-cpu Haswell-noTSX-IBRS,vmx=on \
-cpu host
-m 1024 \
-name u20 \
-drive file=ubuntu-22.04-minimal-cloudimg-amd64.img,if=virtio \
-fsdev local,security_model=passthrough,id=fsdev0,path=/tmp \
-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
```

### Installing proxmox in an virtualized disk using QEMU + KVM


https://forum.proxmox.com/threads/install-proxmox-using-qemu.71284/#post-379953

#### The proxmox image



TODO: use nixpkgs 22.05 release and test it again.

Broken:
```bash
nix \
--option sandbox false \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf")}/nixos/modules/virtualisation/proxmox-image.nix" 

          "${toString (builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf")}/nixos/modules/installer/cd-dvd/channel.nix" 
        ];
    }
  ).config.system.build
)
'
```



From:
- https://github.com/NixOS/nixpkgs/blob/nixos-21.11/nixos/modules/virtualisation/proxmox-image.nix

###

Some copy/paste code only works in copy/paste and don't work when put in a script, and of course,
the other way around, if the used code in a script is copy/pasted, it, in some cases does not work.  
```bash
nano script.sh \
&& chmod +x script.sh \
&& sudo su -c './script.sh'
```


### Vagrant



```bash
sudo groupadd docker; \
sudo usermod --append --groups docker "$USER" \
&& sudo reboot
```

```bash
nix \
profile \
install \
nixpkgs#docker \
&& sudo cp "$(nix eval --raw nixpkgs#docker)"/etc/systemd/system/{docker.service,docker.socket} /etc/systemd/system/ \
&& sudo systemctl enable --now docker
```
Refs.: 
- https://github.com/NixOS/nixpkgs/issues/70407
- https://github.com/moby/moby/tree/e9ab1d425638af916b84d6e0f7f87ef6fa6e6ca9/contrib/init/systemd



```bash
echo 'Start cgroup v2 instalation...' \
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
&& sudo reboot
```

```bash
sudo kind delete cluster
```


https://kind.sigs.k8s.io/docs/user/rootless/#creating-a-kind-cluster-with-rootless-podman

```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs#podman
```


```bash
nix profile install nixpkgs#kind nixpkgs#kubectl
time kind create cluster
```


```bash
kubectl cluster-info --context kind-kind
kubectl get pods -A
```


```bash
kubectl apply -f https://k8s.io/examples/application/shell-demo.yaml

kubectl get pod shell-demo

kubectl exec --stdin --tty shell-demo -- /bin/bash -c 'ls -al /'

kubectl delete pod shell-demo
```




```bash
k0sctl install controller --single
k0sctl init > k0sctl.yaml
test -f "${HOME}"/.ssh/id_rsa || ssh-keygen -t rsa -C "$(git config user.email)" -f "${HOME}"/.ssh/id_rsa -N ''
k0sctl apply --config k0sctl.yaml
```

