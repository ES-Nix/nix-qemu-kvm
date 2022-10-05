


### Alpine

- https://alpinelinux.org/downloads/
- https://wiki.alpinelinux.org/wiki/Install_Alpine_in_Qemu
- https://wiki.alpinelinux.org/wiki/Alpine_setup_scripts#setup-alpine


```bash
wget https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-virt-3.14.2-x86_64.iso
```

```bash
qemu-img \
create \
-f qcow2 \
alpine.qcow2 \
8G
```

```bash
qemu-kvm \
-m 512 \
-nic user \
-boot d \
-cdrom alpine-virt-3.14.2-x86_64.iso \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-cpu host \
-smp $(nproc)
```

```bash
rm -fv alpine.qcow2 \
&& qemu-img \
create \
-f qcow2 \
alpine.qcow2 \
8G \
&& qemu-kvm \
-m 512 \
-nic user \
-boot d \
-cdrom alpine-virt-3.14.2-x86_64.iso \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-cpu host \
-smp $(nproc)
```


Type `root` and press enter:
```bash
root
```

```bash
# echo 'root:123' | chpasswd

export ERASE_DISKS=/dev/sda \
&& { cat << EOF > answerfile
# Customised example answer file for setup-alpine script
# If you don't want to use a certain option, then comment it out

# Use US layout with US variant
KEYMAPOPTS="pt pt"

# Set hostname to 
HOSTNAMEOPTS="-n alpine-vm-qemu-machine"

# Contents of /etc/network/interfaces
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname alpine-vm-qemu-machine
"

# Search domain of example.com, Google public nameserver
DNSOPTS="-d example.com 8.8.8.8"

# Set timezone to UTC
TIMEZONEOPTS="-z UTC"

# set http/ftp proxy
PROXYOPTS="none"

# Add a random mirror
APKREPOSOPTS="-1"

APKCACHEOPTS="/var/cache/apk"

# Install Openssh
SSHDOPTS="-c openssh"

# Use openntpd
NTPOPTS="-c openntpd"

# Use /dev/sda as a data disk
DISKOPTS="-s 2048 -m sys /dev/sda"

EOF
} && setup-alpine -f answerfile \
&& poweroff

#setup-alpine -q
#setup-keymap pt pt
#setup-hostname -n alpine-test
#/etc/init.d/hostname --quiet restart
```

```bash
qemu-kvm \
-m 512 \
-nic user \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-smp $(nproc)
```

```bash
apk update
apk add --no-cache sudo

adduser \
-D \
-G wheel \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

echo 'nixuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nixuser

echo 'nixuser:123' | chpasswd
reboot
# passwd nixuser
```
Adapted from: https://stackoverflow.com/a/54934781

#### Manual installation 

```bash
setup-alpine
```
From: https://wiki.alpinelinux.org/wiki/Install_Alpine_in_Qemu

```bash
pt
pt-nativo
cat 
eth0
dhcp
n
UTC
none
openssh
sda
data
y
none
/var/cache/apk
```


```bash
qemu-kvm \
-m 5000 \
-enable-kvm \
-nographic \
-cdrom alpine-virt-3.14.2-x86_64.iso \
-smp $(nproc)
```



###


```bash
sudo \
apk \
add \
curl \
tar \
xz \
ca-certificates \
openssl


sudo \
apk \
remove \
tar \
xz \
ca-certificates \
openssl
```



```bash
echo '. "$HOME"/.nix-profile/etc/profile.d/nix.sh' >> ~/.profile
```


mkdir -m 4777 /home/nixuser/tmp
export TMPDIR="$HOME"/tmp


```bash
echo 'nixuser:1000000:65535' > /etc/subuid \
&& echo 'nixuser:1000000:65535' > /etc/subgid
```


```bash
podman --log-level=error run -it alpine >> logs.txt 2>&1
```


```bash
podman \
--log-level=error \
run \
--cgroup-manager=cgroupfs \
--cgroups=disabled \
--interactive=true \
--tty=true \
alpine
```

```bash
nix build \
github:ES-Nix/poetry2nix-examples/d55b1d471dd3a7dba878352df465a23e22f60101#poetry2nixOCIImage \
--out-link \
poetry2nixOCIImage.tar.gz

podman load < poetry2nixOCIImage.tar.gz

podman \
run \
--interactive=true \
--rm=true \
--tty=true \
localhost/numtild-dockertools-poetry2nix:0.0.1 \
flask_minimal_example > logs.txt 2>&1
```

```bash
nix profile install nixpkgs#fuse-overlayfs
```


```bash
usermod --add-subuids 100000-165535 "$USER"
usermod --add-subgids 100000-165535 "$USER"
```

```bash
export PATH="$HOME"/.nix-profile/bin:"$PATH"
nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes
```


TODO:
- https://discuss.linuxcontainers.org/t/problems-creating-vm-alpine-with-cloud-init-password/10237/21

#### Refs

- https://stackoverflow.com/a/44581167
- https://stackoverflow.com/questions/38024160/how-to-get-etc-profile-to-run-automatically-in-alpine-docker



stat ~/.ssh 1> /dev/null 2> /dev/null || mkdir -p -m 0600 ~/.ssh

nano ~/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa


rc-update add cgroups
rc-service cgroups start

modprobe tun
echo 'tun' >> /etc/modules
echo 'nixuser:100000:65536' > /etc/subuid
echo 'nixuser:100000:65536' > /etc/subgid


sudo nano /etc/apk/repositories

apk update && apk upgrade

modprobe fuse


nix \
profile \
install \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs#podman

podman run -it  alpine sh


#### alpine arch64 with qemu




https://unix.stackexchange.com/questions/622803/why-qemu-doesnt-install-aarch64-alpine-image-on-x86-64-ubuntu-host

```bash
wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso
wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso.sha256

wget https://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/initramfs-lts
wget https://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/vmlinuz-lts
# wget https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/netboot/modloop-lts


cat alpine-standard-3.16.2-aarch64.iso.sha256 | sha256sum -c

echo '7d4d4a4d7c2293a5377ad00db7f8e33fa7a0422b851f86710df84fb11e628465  initramfs-lts' | sha256sum -c
echo '0271b50b0cc3b1c50cb2e610aa7cfce1180596dc1cad96cc17c95007d3746dbc  vmlinuz-lts' | sha256sum -c
# echo 'd47f97ef54285583301478f88004233880543aac203dcf08a4cb9142b7775a93  modloop-lts' | sha256sum -c
```

```bash
nix profile install nixpkgs#qemu
```

```bash
qemu-img create -f qcow2 alpine-img.qcow2 10G
```

```bash
qemu-system-aarch64 \
-machine virt \
-m 1024 \
-cpu cortex-a57 \
-kernel vmlinuz-lts \
-initrd initramfs-lts \
-append "console=ttyAMA0 ip=dhcp alpine_repo=http://dl-cdn.alpinelinux.org/alpine/edge/main/" \
-nographic
```

```bash
qemu-system-aarch64 \
-machine virt \
-m 1024 \
-cpu cortex-a57 \
-kernel vmlinuz-lts \
-initrd initramfs-lts \
-append "console=ttyAMA0 ip=dhcp alpine_repo=http://dl-cdn.alpinelinux.org/alpine/edge/main/ modloop=http://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/modloop-lts" \
-nographic \
-hda alpine-img.qcow2 \
-device virtio-gpu-pci
```

```bash
setup-alpine -c answerfile
```


```bash
# fdisk -l /dev/vda
export ERASE_DISKS=/dev/vda \
&& { cat << EOF > answerfile
# Example answer file for setup-alpine script
# If you don't want to use a certain option, then comment it out

# Use US layout with US variant
KEYMAPOPTS="pt pt"

# Set hostname to 
HOSTNAMEOPTS="-n alpine-aarch64"

# Set device manager to mdev
DEVDOPTS=mdev

# Contents of /etc/network/interfaces
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname alpine-test
"

# Search domain of example.com, Google public nameserver
# DNSOPTS="-d example.com 8.8.8.8"

# Set timezone to UTC
TIMEZONEOPTS="UTC"
# TIMEZONEOPTS=none

# set http/ftp proxy
#PROXYOPTS="http://webproxy:8080"
PROXYOPTS=none

# Add first mirror (CDN)
APKREPOSOPTS="-1"

# Create admin user
USEROPTS="-a -u -g audio,video,netdev alpineuser"
#USERSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#USERSSHKEY="https://example.com/juser.keys"

# Install Openssh
SSHDOPTS=openssh
#ROOTSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#ROOTSSHKEY="https://example.com/juser.keys"

# Use openntpd
NTPOPTS="openntpd"

# Use /dev/sda as a sys disk
DISKOPTS="-s 2048 -m sys /dev/vda"

# Setup storage with label APKOVL for config storage
#LBUOPTS="LABEL=APKOVL"
LBUOPTS=none

#APKCACHEOPTS="/media/LABEL=APKOVL/cache"
APKCACHEOPTS="/var/cache/apk"

DEFAULT_DISK="-m sys /mnt /dev/vda"
EOF
} && setup-alpine -f answerfile \
&& poweroff
```



```bash
qemu-system-aarch64 \
-machine virt \
-cpu cortex-a57 \
-m 3072M \
-drive file=alpine-img.qcow2 \
-nographic \
-kernel vmlinuz-lts \
-initrd initramfs-lts \
-append "console=ttyAMA0 ip=dhcp alpine_repo=http://dl-cdn.alpinelinux.org/alpine/edge/main/ modloop=http://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/modloop-lts" \
-smp $(nproc)
```


#### The magic nixpkgs#OVMF.fd


```bash
wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-standard-3.16.2-x86_64.iso
wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-standard-3.16.2-x86_64.iso.sha256

cat alpine-standard-3.16.2-x86_64.iso.sha256 | sha256sum -c
```


```bash
nix build nixpkgs#OVMF.fd
FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#OVMF.fd)"/OVMF/OVMF.fd
```

```bash
nix build nixpkgs#qemu
FULL_PATH_FOR_QEMU_SECURE-CODE_FD="$(nix eval --raw nixpkgs#qemu)"/share/qemu/edk2-x86_64-secure-code.fd
```



#### Oneliner


```bash
nix build nixpkgs#OVMF.fd --no-link \
&& FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#OVMF.fd)"/AAVMF/QEMU_EFI-pflash.raw \
&& rm -fv alpine.qcow2 \
&& qemu-img create -f qcow2 alpine.qcow2 10G \
&& qemu-system-aarch64 \
-nic user \
-boot d \
-machine virt \
-cpu cortex-a57 \
-drive if=pflash,format=raw,readonly=on,file="${FULL_PATH_FOR_QEMU_EFI}" \
-m 2048M \
-nographic \
-drive format=raw,readonly=on,file=alpine-standard-3.16.2-aarch64.iso \
-drive file=alpine.qcow2 \
-smp $(nproc)
```

#### The magic QEMU_EFI-pflash.raw



```bash
wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso
wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso.sha256

cat alpine-standard-3.16.2-aarch64.iso.sha256 | sha256sum -c
```


```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd
FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd)"/AAVMF/QEMU_EFI-pflash.raw
```


```bash
rm -fv alpine.qcow2

qemu-img create -f qcow2 alpine.qcow2 10G
```

```bash
qemu-system-aarch64 \
-nic user \
-boot d \
-machine virt \
-cpu cortex-a57 \
-drive if=pflash,format=raw,readonly=on,file="${FULL_PATH_FOR_QEMU_EFI}" \
-m 2048M \
-nographic \
-drive format=raw,readonly=on,file=alpine-standard-3.16.2-aarch64.iso \
-drive file=alpine.qcow2 \
-smp $(nproc)
```

#### Oneliner


```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd --no-link \
&& FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd)"/AAVMF/QEMU_EFI-pflash.raw \
&& rm -fv alpine.qcow2 \
&& qemu-img create -f qcow2 alpine.qcow2 10G \
&& qemu-system-aarch64 \
-nic user \
-boot d \
-machine virt \
-cpu cortex-a57 \
-drive if=pflash,format=raw,readonly=on,file="${FULL_PATH_FOR_QEMU_EFI}" \
-m 2048M \
-nographic \
-drive format=raw,readonly=on,file=alpine-standard-3.16.2-aarch64.iso \
-drive file=alpine.qcow2 \
-smp $(nproc)
```


```bash
setup-alpine
```


```bash
localhost:~# setup-alpine
Enter system hostname (fully qualified form, e.g. 'foo.example.org') [localhost] 
Available interfaces are: eth0.
Enter '?' for help on bridges, bonding and vlans.
Which one do you want to initialize? (or '?' or 'done') [eth0] 
Ip address for eth0? (or 'dhcp', 'none', '?') [dhcp] 
Do you want to do any manual network configuration? (y/n) [n] 
udhcpc: started, v1.35.0
udhcpc: broadcasting discover
udhcpc: broadcasting select for 10.0.2.15, server 10.0.2.2
udhcpc: lease of 10.0.2.15 obtained from 10.0.2.2, lease time 86400
Changing password for root
New password: 
Bad password: too short
Retype password: 
passwd: password for root changed by root
Which timezone are you in? ('?' for list) [UTC] 
 * WARNING: clock skew detected!
 * Saving 256 bits of non-creditable seed for next boot
 * WARNING: clock skew detected!
 * Starting busybox acpid ...
 [ ok ]
 * Starting busybox crond ...
 [ ok ]
HTTP/FTP proxy URL? (e.g. 'http://proxy:8080', or 'none') [none] 
Which NTP client to run? ('busybox', 'openntpd', 'chrony' or 'none') [chrony] 
 * service chronyd added to runlevel default
 * Starting chronyd ...
 [ ok ]

Available mirrors:
1) dl-cdn.alpinelinux.org
2) uk.alpinelinux.org
3) mirror.yandex.ru
4) mirrors.gigenet.com
5) mirror1.hs-esslingen.de
6) mirror.leaseweb.com
7) mirror.fit.cvut.cz
8) alpine.mirror.far.fi
9) alpine.mirror.wearetriple.com
10) mirror.clarkson.edu
11) mirror.aarnet.edu.au
12) mirrors.dotsrc.org
13) ftp.halifax.rwth-aachen.de
14) mirrors.tuna.tsinghua.edu.cn
15) mirrors.ustc.edu.cn
16) mirrors.nju.edu.cn
17) mirror.lzu.edu.cn
18) ftp.acc.umu.se
19) mirror.xtom.com.hk
20) mirror.csclub.uwaterloo.ca
21) alpinelinux.mirror.iweb.com
22) pkg.adfinis.com
23) mirror.ps.kz
24) mirror.rise.ph
25) mirror.operationtulip.com
26) mirrors.ircam.fr
27) mirror.math.princeton.edu
28) mirrors.sjtug.sjtu.edu.cn
29) ftp.icm.edu.pl
30) mirror.ungleich.ch
31) mirrors.edge.kernel.org
32) ap.edge.kernel.org
33) eu.edge.kernel.org
34) download.nus.edu.sg
35) alpine.yourlabs.org
36) mirror.pit.teraswitch.com
37) mirror.reenigne.net
38) quantum-mirror.hu
39) tux.rainside.sk
40) alpine.cs.nycu.edu.tw
41) mirror.ihost.md
42) mirror.ette.biz
43) mirror.lagoon.nc
44) alpinelinux.c3sl.ufpr.br
45) foobar.turbo.net.id
46) alpine.ccns.ncku.edu.tw
47) mirror.dst.ca
48) mirror.kumi.systems
49) mirror.sabay.com.kh
50) alpine.northrepo.ca
51) alpine.bardia.tech
52) mirrors.ocf.berkeley.edu
53) mirrors.pardisco.co
54) mirrors.aliyun.com
55) mirror.alwyzon.net
56) mirror1.ku.ac.th
57) mirrors.bfsu.edu.cn
58) ftpmirror2.infania.net
59) repo.iut.ac.ir
60) mirror.fcix.net
61) alpine.sakamoto.pl
62) mirror.2degrees.nz
63) mirror.arvancloud.com
64) mirror.0-1.cloud
65) mirror.kku.ac.th
66) mirror.uepg.br
67) alpine.astra.in.ua
68) mirrors.neusoft.edu.cn
69) ftp.udx.icscoe.jp
70) alpinelinux.mirror.garr.it
71) mirrors.hostico.ro
72) mirror.serverion.com
73) alpinelinux.qontinuum.space
74) alpine.kyberorg.fi

r) Add random from the above list
f) Detect and add fastest mirror from above list
e) Edit /etc/apk/repositories with text editor

Enter mirror number (1-74) or URL to add (or r/f/e/done) [1] 
Added mirror dl-cdn.alpinelinux.org
Updating repository indexes... done.
Setup a user? (enter a lower-case loginname, or 'no') [no] 
Which ssh server? ('openssh', 'dropbear' or 'none') [openssh] 
Allow root ssh login? ('?' for help) [prohibit-password] 
Enter ssh key or URL for root (or 'none') [none] 
 * service sshd added to runlevel default
 * Caching service dependencies ...
 [ ok ]
ssh-keygen: generating new host keys: RSA DSA ECDSA ED25519 
 * Starting sshd ...
 [ ok ]
Available disks are:
  vdb   (10.7 GB 0x1af4 )
Which disk(s) would you like to use? (or '?' for help or 'none') [none] vdb
The following disk is selected:
  vdb   (10.7 GB 0x1af4 )
How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?' for help) [?] sys
WARNING: The following disk(s) will be erased:
  vdb   (10.7 GB 0x1af4 )
WARNING: Erase the above disk(s) and continue? (y/n) [n] y
Creating file systems...
mkfs.fat 4.2 (2021-01-31)
Installing system on /dev/vdb3:
Installing for arm64-efi platform.
Installation finished. No error reported.       
100% ████████████████████████████████████████████==> initramfs: creating /boot/initramfs-lts
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-lts
Found initrd image: /boot/initramfs-lts
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
done

Installation is complete. Please reboot.
```



```bash
setup-alpine -c answerfile
```


```bash
setup-alpine -q
```


```bash
# fdisk -l /dev/vda

export ERASE_DISKS=/dev/vda \
&& { cat << EOF > answerfile
# Customised example answer file for setup-alpine script
# If you don't want to use a certain option, then comment it out

# Use US layout with US variant
KEYMAPOPTS="pt pt"

# Set hostname to 
HOSTNAMEOPTS="-n alpine-aarch64"

# Contents of /etc/network/interfaces
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname alpine-vm-qemu-machine
"

# Search domain of example.com, Google public nameserver
DNSOPTS="-d example.com 8.8.8.8"

# Set timezone to UTC
TIMEZONEOPTS="-z UTC"

# set http/ftp proxy
PROXYOPTS="none"

# Add a random mirror
APKREPOSOPTS="-1"

APKCACHEOPTS="/var/cache/apk"

# Install Openssh
SSHDOPTS="-c openssh"

# Use openntpd
NTPOPTS="-c openntpd"

# Use /dev/sda as a data disk
DISKOPTS="-s 2048 -m sys /dev/vda"

EOF
} && setup-alpine -f answerfile \
&& poweroff
```



```bash
qemu-system-aarch64 \
-machine virt \
-cpu cortex-a57 \
-drive if=pflash,format=raw,readonly=on,file="${FULL_PATH_FOR_QEMU_EFI}" \
-m 2048M \
-nographic \
-drive file=alpine.qcow2 \
-smp $(nproc)
```


```bash
apk update
apk add --no-cache sudo

adduser \
-D \
-G wheel \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

echo 'nixuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nixuser

echo 'nixuser:123' | chpasswd
reboot
# passwd nixuser
```
Adapted from: https://stackoverflow.com/a/54934781


```bash
adduser \
-D \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

echo 'nixuser:123' | chpasswd
```


```bash
apk add alpine-sdk doas curl xz
```
From:
- https://wiki.alpinelinux.org/wiki/Include:Setup_your_system_and_account_for_building_packages
- https://unix.stackexchange.com/questions/689678/automate-alpine-linux-installation#comment1320137_689678
- https://wejn.org/2022/04/alpinelinux-unattended-install/


```bash
test -d /etc/doas.d || mkdir -p /etc/doas.d

echo 'permit persist :wheel' >> /etc/doas.d/doas.conf
```
From: https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#Options

```bash
# Run as root
modprobe tun \
&& echo tun >> /etc/modules \
&& echo nixuser:100000:65536 > /etc/subuid \
&& echo nixuser:100000:65536 > /etc/subgid \
&& rc-update add cgroups \
&& rc-service cgroups start
```

```bash
reboot
```



```bash
cp .bashrc .profile
. ~/.nix-profile/etc/profile.d/nix.sh 
```




```bash
nix \
profile \
install \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs#podman
```



Broken, did not work:
```bash
apk add doas-sudo-shim
```
https://news.ycombinator.com/item?id=29330394



### NixOS ARM in non-NixOS GNU/linux systems emulated using QEMU + KVM   


https://discourse.nixos.org/t/failing-to-use-nixos-on-arm-by-compiling-through-qemu/7844




##### Install nix

https://github.com/ES-Nix/get-nix/tree/draft-in-wip#single-user



```bash
mkdir -pv ~/test-qemu-arm \
&& cd ~/test-qemu-arm
```


```bash
echo 'Started!' \
&& { cat << 'EOF' > qemu.nix
{ config, pkgs, lib, ... }:

let
  cfg = config.qemu-user;
  arm = {
    interpreter = "${pkgs.qemu-user-arm}/bin/qemu-arm";
    magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };
  aarch64 = {
    interpreter = "${pkgs.qemu-user-arm64}/bin/qemu-aarch64";
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };
  riscv64 = {
    interpreter = "${pkgs.qemu-riscv64}/bin/qemu-riscv64";
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };
in with lib; {
  options = {
    qemu-user = {
      arm = mkEnableOption "enable 32bit arm emulation";
      aarch64 = mkEnableOption "enable 64bit arm emulation";
      riscv64 = mkEnableOption "enable 64bit riscv emulation";
    };
    nix.supportedPlatforms = mkOption {
      type = types.listOf types.str;
      description = "extra platforms that nix will run binaries for";
      default = [];
    };
  };
  config = mkIf (cfg.arm || cfg.aarch64) {
    boot.binfmt.registrations =
      optionalAttrs cfg.arm { inherit arm; } //
      optionalAttrs cfg.aarch64 { inherit aarch64; } //
      optionalAttrs cfg.riscv64 { inherit riscv64; };
    nix.supportedPlatforms = (optionals cfg.arm [ "armv6l-linux" "armv7l-linux" ])
      ++ (optional cfg.aarch64 "aarch64-linux");
    nix.extraOptions = ''
      extra-platforms = ${toString config.nix.supportedPlatforms} i686-linux
    '';
    nix.sandboxPaths = [ "/run/binfmt" ] ++ (optional cfg.arm "${pkgs.qemu-user-arm}") ++ (optional cfg.aarch64 "${pkgs.qemu-user-arm64}");
  };
}
EOF
} && echo
```

```bash
echo 'Started!' \
&& { cat << 'EOF' > qemu-wrap.c


EOF
} && echo
```


```bash
echo 'Started!' \
&& { cat << 'EOF' > qemu-stack.patch
--- a/linux-user/elfload.c	2016-09-02 12:34:22.000000000 -0300
+++ b/linux-user/elfload.c	2017-07-09 18:44:22.420244038 -0300
@@ -1419,7 +1419,7 @@
  * dependent on stack size, but guarantee at least 32 pages for
  * backwards compatibility.
  */
-#define STACK_LOWER_LIMIT (32 * TARGET_PAGE_SIZE)
+#define STACK_LOWER_LIMIT (128 * TARGET_PAGE_SIZE)
 
 static abi_ulong setup_arg_pages(struct linux_binprm *bprm,
                                  struct image_info *info)
EOF
} && echo
```


```bash
echo 'Started!' \
&& { cat << 'EOF' > default.nix
{ stdenv, fetchurl, python, pkgconfig, zlib, glib, user_arch, flex, bison,
makeStaticLibraries, glibc, qemu, fetchFromGitHub }:

let
  env2 = makeStaticLibraries stdenv;
  myglib = (glib.override { stdenv = env2; }).overrideAttrs (drv: {
    mesonFlags = (drv.mesonFlags or []) ++ [ "-Ddefault_library=both" ];
  });
  riscv_src = fetchFromGitHub {
    owner = "riscv";
    repo = "riscv-qemu";
    rev = "7d2d2add16aff0304ab0c279152548dbd04a2138"; # riscv-all
    sha256 = "16an7ifi2ifzqnlz0218rmbxq9vid434j98g14141qvlcl7gzsy2";
  };
  is_riscv = (user_arch == "riscv32") || (user_arch == "riscv64");
  arch_map = {
    arm = "i386";
    aarch64 = "x86_64";
    riscv64 = "x86_64";
    x86_64 = "x86_64";
  };
in
stdenv.mkDerivation rec {
  name = "qemu-user-${user_arch}-${version}";
  version = "3.1.0";
  src = if is_riscv then riscv_src else qemu.src;
  buildInputs = [ python pkgconfig zlib.static myglib flex bison glibc.static ];
  patches = [ ./qemu-stack.patch ];
  configureFlags = [
    "--enable-linux-user" "--target-list=${user_arch}-linux-user"
    "--disable-bsd-user" "--disable-system" "--disable-vnc"
    "--disable-curses" "--disable-sdl" "--disable-vde"
    "--disable-bluez" "--disable-kvm"
    "--static"
    "--disable-tools"
    "--cpu=${arch_map.${user_arch}}"
  ];
  NIX_LDFLAGS = [ "-lglib-2.0" ];
  enableParallelBuilding = true;
  postInstall = ''
    cc -static ${./qemu-wrap.c} -D QEMU_ARM_BIN="\"qemu-${user_arch}"\" -o $out/bin/qemu-wrap
  '';
}
EOF
} && echo
```


```bash
echo 'Started!' \
&& { cat << 'EOF' > vm-config.nix
let
  qemuOverlay = (import ./overlays/qemu);
in
{
  imports = [
    ./qemu.nix
  ];

  config = {
    boot.kernelModules = [ "kvm-intel" ];

    qemu-user.aarch64 = true;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    nix = {
      trustedUsers = [ "573" "builder" ];
    };

    users.users.builder = {
      createHome = true;
      isNormalUser = true;
    };
  };
}
EOF
} && echo
```


```bash
echo 'Started!' \
&& { cat << 'EOF' > vm.nix
{ config, lib, pkgs, ... }:

with lib;

{
  imports =
    [ <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      ./vm-config.nix
    ];

  system.build.qemuvmImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit lib config;
    pkgs = import <nixpkgs/nixos> { inherit (pkgs) system; }; # ensure we use the regular qemu-kvm package
    diskSize = 8192;
    format = "qcow2";
    configFile = pkgs.writeText "configuration.nix"
      ''
        {
          imports = [ <./machine-config.nix> ];
        }
      '';
    };
}
EOF
} && echo
```




### The cloud-init


https://cloud-init.io/

https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/community/cloud-init/README.Alpine


> After the cloud-init package is installed you will need to run the
> "setup-cloud-init" command to prepare the OS for cloud-init use.
From: https://git.alpinelinux.org/aports/tree/community/cloud-init/README.Alpine


TODO:
- https://christine.website/blog/cloud-init-2021-06-04

