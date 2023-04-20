


## Alpine

- https://alpinelinux.org/downloads/
- https://wiki.alpinelinux.org/wiki/Install_Alpine_in_Qemu
- https://wiki.alpinelinux.org/wiki/Alpine_setup_scripts#setup-alpine

#### Alpine 3.14.2 x86_64

```bash
command -v qemu-img || nix profile install nixpkgs#qemu
command -v wget || nix profile install nixpkgs#wget

rm -fv alpine.qcow2; qemu-img create -f qcow2 alpine.qcow2 10G

test -f alpine-virt-3.14.2-x86_64.iso \
|| wget https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-virt-3.14.2-x86_64.iso
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


Type `root` and press enter:
```bash
root
```

```bash
DISK_NAME=sda
export ERASE_DISKS=/dev/$DISK_NAME \
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

# Use /dev/$DISK_NAME as a data disk
DISKOPTS="-s 2048 -m sys /dev/$DISK_NAME"

EOF
} && setup-alpine -f answerfile \
&& poweroff
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
```
Adapted from: https://stackoverflow.com/a/54934781


#### Alpine 3.16.2, qemu, kvm


```bash
command -v qemu-img || nix profile install nixpkgs#qemu
command -v wget || nix profile install nixpkgs#wget

rm -fv alpine.qcow2
qemu-img create -f qcow2 alpine.qcow2 10G

test -f alpine-virt-3.16.2-x86_64.iso \
|| wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.2-x86_64.iso

qemu-kvm \
-m 1024M \
-nic user \
-boot d \
-cdrom alpine-virt-3.16.2-x86_64.iso \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-cpu host \
-smp $(nproc)
```

```bash
qemu-system-x86_64 \
-m 2048M \
-nic user \
-boot d \
-cdrom alpine-virt-3.16.2-x86_64.iso  \
-hda alpine.qcow2 \
-nographic \
-cpu Haswell \
-smp 4
```


Type `root` and press enter:
```bash
root
```

> Note: It is different from the 3.14.2!
```bash
DISK_NAME=sda
# fdisk -l /dev/$DISK_NAME
export ERASE_DISKS=/dev/$DISK_NAME \
&& { cat << EOF > answerfile
# Example answer file for setup-alpine script
# If you don't want to use a certain option, then comment it out

# Use US layout with US variant
KEYMAPOPTS="pt pt"

# Set hostname to 
HOSTNAMEOPTS="-n alpine-x8664"

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
TIMEZONEOPTS="-z UTC"
# TIMEZONEOPTS=none

# set http/ftp proxy
#PROXYOPTS="http://webproxy:8080"
PROXYOPTS=none

# Add first mirror (CDN)
APKREPOSOPTS="-1"

# Create admin user
USEROPTS="-a -u -g audio,video,netdev nixuser"
#USERSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#USERSSHKEY="https://example.com/juser.keys"

# Install Openssh
SSHDOPTS="-c openssh"
#ROOTSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#ROOTSSHKEY="https://example.com/juser.keys"

# Use openntpd
NTPOPTS="-c openntpd"

# Use /dev/sdb as a sys disk
DISKOPTS="-s 2048 -m sys /dev/$DISK_NAME"

# Setup storage with label APKOVL for config storage
#LBUOPTS="LABEL=APKOVL"
LBUOPTS=none

#APKCACHEOPTS="/media/LABEL=APKOVL/cache"
APKCACHEOPTS="/var/cache/apk"

DEFAULT_DISK="-m sys /mnt /dev/$DISK_NAME"
EOF
} && setup-alpine -f answerfile \
&& poweroff
```

```bash
cp -fv alpine.qcow2 alpine-just-installed.qcow2
```

```bash
qemu-kvm \
-m 2048M \
-nic user \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-smp $(nproc)
```

It must be possible to login as `root` or as `nixuser`.

> It probably comes from `USEROPTS="-a -u -g audio,video,netdev nixuser"`

Run as root:
```bash
# If using USEROPTS it is not needed to create the user here
#adduser \
#-D \
#-G wheel \
#-s /bin/sh \
#-h /home/nixuser \
#-g "User" nixuser

echo 'nixuser:123' | chpasswd

apk add alpine-sdk doas curl xz

test -d /etc/doas.d || mkdir -p /etc/doas.d
echo 'permit persist :wheel' >> /etc/doas.d/doas.conf

modprobe tun \
&& echo tun >> /etc/modules \
&& echo nixuser:100000:65536 > /etc/subuid \
&& echo nixuser:100000:65536 > /etc/subgid \
&& rc-update add cgroups \
&& rc-service cgroups start \
&& reboot
```
From:
- https://wiki.alpinelinux.org/wiki/Include:Setup_your_system_and_account_for_building_packages
- https://unix.stackexchange.com/questions/689678/automate-alpine-linux-installation#comment1320137_689678
- https://wejn.org/2022/04/alpinelinux-unattended-install/
- https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#Options


```bash
cp -fv  alpine.qcow2 alpine-with-nixuser.qcow2
```


```bash
doas mkdir -pv -m 0755 /nix \
&& doas chown -v "$(id -u)":"$(id -g)" /nix \
&& BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& NIX_RELEASE_VERSION='2.10.2' \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version

echo '. "$HOME"/.nix-profile/etc/profile.d/nix.sh' >> ~/.profile
. ~/.profile
nix flake --version

doas poweroff
```

```bash
cp -fv  alpine.qcow2 alpine-with-nixuser-and-nix.qcow2
```

```bash
nix \
profile \
install \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs#podman

podman run -it --rm ubuntu bash
```



```bash
qemu-kvm \
-m 1048M \
-nic user \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-smp $(nproc) \
-net nic,model=virtio \
-net user,hostfwd=tcp:127.0.0.1:9000-:9000 \
-device virtio-gpu-pci \
-device virtio-keyboard-pci
```

```bash
nix run nixpkgs#python3 -- -m http.server 9000
```

```bash
# Broken as of now
nix shell nixpkgs#pkgsStatic.python3Minimal --command python -m http.server 9000
```

```bash
test $(curl -s -w '%{http_code}\n' localhost:9000 -o /dev/null) -eq 200 || echo 'Error'
```

### Manual installation (Incomplete)

```bash
setup-alpine
```
From: https://wiki.alpinelinux.org/wiki/Install_Alpine_in_Qemu


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
nix \
build \
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

podman run -it alpine sh


#### alpine arch64 with qemu



https://unix.stackexchange.com/questions/622803/why-qemu-doesnt-install-aarch64-alpine-image-on-x86-64-ubuntu-host

```bash
test -f alpine-standard-3.16.2-aarch64.iso || wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso
test -f alpine-standard-3.16.2-aarch64.iso.sha256 || wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso.sha256

test -f initramfs-lts || wget https://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/initramfs-lts
test -f vmlinuz-lts || wget https://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/vmlinuz-lts
test -f modloop-lts || wget https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/netboot/modloop-lts


cat alpine-standard-3.16.2-aarch64.iso.sha256 | sha256sum -c

echo '7ce36b75e74ee8b87c3330174c682859c860efba32ba346b828f91f72b25d76a  initramfs-lts' | sha256sum -c
echo '7cd248614ca4abbc416442d9cfb2086f377b907014f53ad3f6d3516deff4a80f  vmlinuz-lts' | sha256sum -c
echo 'd47f97ef54285583301478f88004233880543aac203dcf08a4cb9142b7775a93  modloop-lts' | sha256sum -c
```

```bash
command -v qemu-img || nix profile install nixpkgs#qemu

rm -fv alpine-img.qcow2; qemu-img create -f qcow2 alpine-img.qcow2 10G

qemu-system-aarch64 \
-machine virt \
-m 1024 \
-cpu cortex-a57 \
-kernel vmlinuz-lts \
-initrd initramfs-lts \
-append "console=ttyAMA0 ip=dhcp alpine_repo=http://dl-cdn.alpinelinux.org/alpine/edge/main/ modloop=http://dl-cdn.alpinelinux.org/alpine/edge/releases/aarch64/netboot/modloop-lts" \
-nographic \
-hda alpine-img.qcow2 \
-drive format=raw,readonly=on,file=alpine-standard-3.16.2-aarch64.iso \
-device virtio-gpu-pci
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
-append "console=ttyAMA0 ip=dhcp" \
-nographic
```

```bash
#setup-alpine -c answerfile
```


```bash
apk add e2fsprogs lsblk parted

parted /dev/vda mklabel gpt
parted -a opt /dev/vda mkpart primary ext4 0% 100%

mkfs.ext4 -L datapartition /dev/vda1
lsblk --fs
lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT
```


It worked:
```bash
DISK_NAME=vda

# fdisk -l /dev/$DISK_NAME
# fdisk -l /dev/vda


apk add e2fsprogs lsblk parted

parted /dev/$DISK_NAME mklabel gpt
parted -a opt /dev/$DISK_NAME mkpart primary ext4 0% 100%

mkfs.ext4 -L datapartition /dev/"$DISK_NAME"1
lsblk --fs
lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT


export ERASE_DISKS=/dev/"$DISK_NAME" \
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
    hostname alpine-aarch64
"

# Search domain of example.com, Google public nameserver
DNSOPTS="-d nameserver 8.8.8.8"

# Set timezone to UTC
TIMEZONEOPTS="-z UTC"
# TIMEZONEOPTS=none

# set http/ftp proxy
#PROXYOPTS="http://webproxy:8080"
PROXYOPTS=none

# Add first mirror (CDN)
APKREPOSOPTS="-1"
# https://it-wars.com/posts/devops/iac-packer-terraform-ansible-libvirt-dnscrypt/
# APKREPOSOPTS="http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/"
# APKREPOSOPTS="http://dl-cdn.alpinelinux.org/alpine/edge/main/"

# Create admin user
USEROPTS="-a -u -g audio,video,netdev,wheel nixuser"
#USERSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#USERSSHKEY="https://example.com/juser.keys"

# Install Openssh
SSHDOPTS="-c openssh"
#ROOTSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#ROOTSSHKEY="https://example.com/juser.keys"

# Use openntpd
# NTPOPTS="-c openntpd"
NTPOPTS=none

# Use /dev/vda as a sys disk
DISKOPTS="-s 2048 -m sys /dev/$DISK_NAME"

# Setup storage with label APKOVL for config storage
# LBUOPTS="LABEL=APKOVL"
LBUOPTS=none

#APKCACHEOPTS="/media/LABEL=APKOVL/cache"
# APKCACHEOPTS="/var/cache/apk"


# https://gitlab.alpinelinux.org/alpine/aports/-/issues/12353#note_138692
DEFAULT_DISK="-m sys /mnt /dev/$DISK_NAME"
EOF
} && setup-alpine -f answerfile \
&& poweroff
```
Refs.:
- https://gparted.org/h2-fix-msdos-pt.php


```bash
ping dl-cdn.alpinelinux.org
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

Broken:
```bash
apk update
apk add --no-cache sudo

adduser \
-D \
-G wheel \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

test -d /etc/sudoers.d || mkdir -pv /etc/sudoers.d
echo 'nixuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nixuser

echo 'nixuser:123' | chpasswd
reboot
```
Adapted from: https://stackoverflow.com/a/54934781


Run as root:
```bash
apk add alpine-sdk doas curl xz

adduser \
-D \
-G wheel \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

echo 'nixuser:123' | chpasswd

test -d /etc/doas.d || mkdir -p /etc/doas.d

echo 'permit persist :wheel' >> /etc/doas.d/doas.conf

modprobe tun \
&& echo tun >> /etc/modules \
&& echo nixuser:100000:65536 > /etc/subuid \
&& echo nixuser:100000:65536 > /etc/subgid \
&& rc-update add cgroups \
&& rc-service cgroups start \
&& reboot
```
From:
- https://wiki.alpinelinux.org/wiki/Include:Setup_your_system_and_account_for_building_packages
- https://unix.stackexchange.com/questions/689678/automate-alpine-linux-installation#comment1320137_689678
- https://wejn.org/2022/04/alpinelinux-unattended-install/
- https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#Options


```bash
reboot
```


#### The magic nixpkgs#OVMF.fd, x86_64


```bash
BASE_URL='https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/'
test -f alpine-standard-3.16.2-x86_64.iso || wget "${BASE_URL}"alpine-standard-3.16.2-x86_64.iso
test -f alpine-standard-3.16.2-x86_64.iso.sha256 || wget "${BASE_URL}"alpine-standard-3.16.2-x86_64.iso.sha256

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
&& FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#OVMF.fd)"/FV/OVMF.fd \
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

#### The magic QEMU_EFI-pflash.raw, QEMU, KVM, aarch64, Alpine 3.16.2



```bash
test -f alpine-standard-3.16.2-aarch64.iso \
|| wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso
test -f alpine-standard-3.16.2-aarch64.iso.sha256 \
|| wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-standard-3.16.2-aarch64.iso.sha256

cat alpine-standard-3.16.2-aarch64.iso.sha256 | sha256sum -c

nix build nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd --no-link
FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd)"/AAVMF/QEMU_EFI-pflash.raw

# No estate
rm -fv alpine.qcow2
qemu-img create -f qcow2 alpine.qcow2 10G

qemu-system-aarch64 \
-net user \
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

wget https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.2-live-server-arm64.iso


```bash
# fdisk -l /dev/vdb
export ERASE_DISKS=/dev/vdb \
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
TIMEZONEOPTS="-z UTC"
# TIMEZONEOPTS=none

# set http/ftp proxy
#PROXYOPTS="http://webproxy:8080"
PROXYOPTS=none

# Add first mirror (CDN)
APKREPOSOPTS="-1"

# Create admin user
USEROPTS="-a -u -g audio,video,netdev nixuser"
#USERSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#USERSSHKEY="https://example.com/juser.keys"

# Install Openssh
# SSHDOPTS="-c openssh"
SSHDOPTS="none"
#ROOTSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#ROOTSSHKEY="https://example.com/juser.keys"

# Use openntpd
# NTPOPTS="-c openntpd"

# Use /dev/sdb as a sys disk
DISKOPTS="-s 2048 -m sys /dev/$DISK_NAME"

# Setup storage with label APKOVL for config storage
#LBUOPTS="LABEL=APKOVL"
LBUOPTS=none

#APKCACHEOPTS="/media/LABEL=APKOVL/cache"
APKCACHEOPTS="/var/cache/apk"

DEFAULT_DISK="-m sys /mnt /dev/vdb"
EOF
} && setup-alpine -f answerfile \
&& poweroff
```



```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd --no-link \
&& FULL_PATH_FOR_QEMU_EFI="$(nix eval --raw nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd)"/AAVMF/QEMU_EFI-pflash.raw
qemu-system-aarch64 \
-machine virt \
-cpu cortex-a57 \
-drive if=pflash,format=raw,readonly=on,file="${FULL_PATH_FOR_QEMU_EFI}" \
-m 4096M \
-nographic \
-drive file=alpine.qcow2 \
-smp $(nproc)
```

Run as root:
```bash
adduser \
-D \
-G wheel \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

echo 'nixuser:123' | chpasswd

apk add alpine-sdk doas curl xz

test -d /etc/doas.d || mkdir -p /etc/doas.d
echo 'permit persist :wheel' >> /etc/doas.d/doas.conf

modprobe tun \
&& echo tun >> /etc/modules \
&& echo nixuser:100000:65536 > /etc/subuid \
&& echo nixuser:100000:65536 > /etc/subgid \
&& rc-update add cgroups \
&& rc-service cgroups start \
&& reboot
```
From:
- https://wiki.alpinelinux.org/wiki/Include:Setup_your_system_and_account_for_building_packages
- https://unix.stackexchange.com/questions/689678/automate-alpine-linux-installation#comment1320137_689678
- https://wejn.org/2022/04/alpinelinux-unattended-install/
- https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#Options


##### NixOS Intel x86_64 -> QEMU -> arm -> amd, x86_64 -> aarch64


```bash
doas mkdir -pv -m 0755 /nix
doas chown -v "$(id -u)":"$(id -g)" /nix
```


```bash
BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& NIX_RELEASE_VERSION='2.10.2' \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version
```

```bash
echo '. "$HOME"/.nix-profile/etc/profile.d/nix.sh' >> ~/.profile
```


```bash
command -v qemu-img || nix profile install nixpkgs#qemu
command -v wget || nix profile install nixpkgs#wget

rm -fv alpine.qcow2
qemu-img create -f qcow2 alpine.qcow2 8G

# wget https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-virt-3.14.2-x86_64.iso
BASE_URL='https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/'
test -f alpine-standard-3.16.2-x86_64.iso || wget "${BASE_URL}"alpine-standard-3.16.2-x86_64.iso
test -f alpine-standard-3.16.2-x86_64.iso.sha256 || wget "${BASE_URL}"alpine-standard-3.16.2-x86_64.iso.sha256

cat alpine-standard-3.16.2-x86_64.iso.sha256 | sha256sum -c


qemu-system-x86_64 \
-m 2048M \
-nic user \
-boot d \
-cdrom alpine-standard-3.16.2-x86_64.iso \
-hda alpine.qcow2 \
-nographic \
-cpu Haswell-noTSX-IBRS,vmx=on \
-smp $(nproc)
```


```bash
# fdisk -l /dev/$DISK_NAME
DISK_NAME=sda
export ERASE_DISKS=/dev/$DISK_NAME \
&& { cat << EOF > answerfile
# Example answer file for setup-alpine script
# If you don't want to use a certain option, then comment it out

# Use US layout with US variant
KEYMAPOPTS="pt pt"

# Set hostname to 
HOSTNAMEOPTS="-n alpine-x8664"

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
TIMEZONEOPTS="-z UTC"
# TIMEZONEOPTS=none

# set http/ftp proxy
#PROXYOPTS="http://webproxy:8080"
PROXYOPTS=none

# Add first mirror (CDN)
APKREPOSOPTS="-1"

# Create admin user
USEROPTS="-a -u -g audio,video,netdev nixuser"
#USERSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#USERSSHKEY="https://example.com/juser.keys"

# Install Openssh
SSHDOPTS="-c openssh"
#ROOTSSHKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIiHcbg/7ytfLFHUNLRgEAubFz/13SwXBOM/05GNZe4 juser@example.com"
#ROOTSSHKEY="https://example.com/juser.keys"

# Use openntpd
NTPOPTS="-c openntpd"

# Use /dev/sdb as a sys disk
DISKOPTS="-s 2048 -m sys /dev/$DISK_NAME"

# Setup storage with label APKOVL for config storage
#LBUOPTS="LABEL=APKOVL"
LBUOPTS=none

#APKCACHEOPTS="/media/LABEL=APKOVL/cache"
APKCACHEOPTS="/var/cache/apk"

DEFAULT_DISK="-m sys /mnt /dev/$DISK_NAME"
EOF
} && setup-alpine -f answerfile \
&& poweroff
```


```bash
qemu-system-x86_64 \
-cpu Haswell-noTSX-IBRS,vmx=on \
-enable-kvm \
-m 2048M \
-nographic \
-drive file=alpine.qcow2 \
-smp $(nproc)
```


Run as root:
```bash
#adduser \
#-D \
#-G wheel \
#-s /bin/sh \
#-h /home/nixuser \
#-g "User" nixuser

echo 'nixuser:123' | chpasswd

apk add --no-cache alpine-sdk doas curl xz

test -d /etc/doas.d || mkdir -p /etc/doas.d

echo 'permit persist :wheel' >> /etc/doas.d/doas.conf

modprobe tun \
&& echo tun >> /etc/modules \
&& echo nixuser:100000:65536 > /etc/subuid \
&& echo nixuser:100000:65536 > /etc/subgid \
&& rc-update add cgroups \
&& rc-service cgroups start \
&& reboot
```
From:
- https://wiki.alpinelinux.org/wiki/Include:Setup_your_system_and_account_for_building_packages
- https://unix.stackexchange.com/questions/689678/automate-alpine-linux-installation#comment1320137_689678
- https://wejn.org/2022/04/alpinelinux-unattended-install/
- https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#Options




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



```bash
#apk update
#apk add --no-cache sudo
#
#adduser \
#-D \
#-G wheel \
#-s /bin/sh \
#-h /home/nixuser \
#-g "User" nixuser
#
#test -d /etc/sudoers.d || mkdir -pv /etc/sudoers.d
#echo 'nixuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nixuser
#
#echo 'nixuser:123' | chpasswd
#reboot
# passwd nixuser
```
Adapted from: https://stackoverflow.com/a/54934781


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

