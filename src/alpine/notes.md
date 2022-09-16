


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


### The cloud-init


https://cloud-init.io/

https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/community/cloud-init/README.Alpine


> After the cloud-init package is installed you will need to run the
> "setup-cloud-init" command to prepare the OS for cloud-init use.
From: https://git.alpinelinux.org/aports/tree/community/cloud-init/README.Alpine


TODO:
- https://christine.website/blog/cloud-init-2021-06-04

