


### Alpine

- https://alpinelinux.org/downloads/
- https://wiki.alpinelinux.org/wiki/Install_Alpine_in_Qemu
- https://wiki.alpinelinux.org/wiki/Alpine_setup_scripts#setup-alpine


wget https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-virt-3.14.2-x86_64.iso

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
setup-alpine
```
From: https://wiki.alpinelinux.org/wiki/Install_Alpine_in_Qemu

```bash
qemu-kvm \
-m 512 \
-nic user \
-hda alpine.qcow2 \
-nographic \
-enable-kvm \
-cpu host \
-smp $(nproc)
```

```bash
apk add --no-cache sudo

adduser \
-D \
-G wheel \
-s /bin/sh \
-h /home/nixuser \
-g "User" nixuser

echo 'nixuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nixuser

passwd nixuser
```
Adapeted from: https://stackoverflow.com/a/54934781


```bash
sudo \
apk \
add \
curl \
tar \
xz \
ca-certificates \
openssl

cat <<WRAP > "$HOME"/.profile
# It was inserted by the get-nix installer
flake () {
    echo "Entering the nix + flake shell.";
    # Would it be usefull to have the "" to pass arguments?
    nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes;
}
nd () {
   nix-collect-garbage --delete-old;
}
develop () {
    echo "Entering the nix + flake development shell.";
    nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix develop';
}
export TMPDIR=/tmp
. "\$HOME"/.nix-profile/etc/profile.d/nix.sh
# End of inserted by the get-nix installer
WRAP

test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/.profile \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="$(readlink -f $(which nix))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version


sudo \
apk \ 
remove \
tar \
xz \
ca-certificates \
openssl
```

export PATH="$HOME"/.nix-profile/bin:"$PATH"
nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes

mkdir -m 7777 /home/nixuser/tmp
export TMPDIR="$HOME"/tmp

echo 'nixuser:1000000:65536' >> /etc/subuid \
&& echo 'nixgroup:1000000:65536' >> /etc/subgid


echo 'nixuser:100000:165535' > /etc/subuid \
&& echo 'nixuser:100000:165535' > /etc/subgid

export PATH="$HOME"/.nix-profile/bin:"$PATH"


podman --log-level=error run -it alpine >> logs.txt 2>&1



podman \
--log-level=error \
run \
--cgroup-manager=cgroupfs \
--cgroups=disabled \
-it \
alpine


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

nix profile install nixpkgs#fuse-overlayfs


usermod --add-subuids 100000-165535 "$USER"
usermod --add-subgids 100000-165535 "$USER"


export PATH="$HOME"/.nix-profile/bin:"$PATH"
nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes

TODO:
- https://discuss.linuxcontainers.org/t/problems-creating-vm-alpine-with-cloud-init-password/10237/21

#### Refs

- https://stackoverflow.com/a/44581167
- https://stackoverflow.com/questions/38024160/how-to-get-etc-profile-to-run-automatically-in-alpine-docker


