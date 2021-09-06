

### All from curl: minikube, kubectl, docker, helm

```bash
kill -9 $(pidof qemu-system-x86_64) || true \
&& result/refresh || nix build .#qemu.vm \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
echo 'Start minikube stuff...' \
&& curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
&& chmod -v 0755 minikube \
&& sudo mv -v minikube /usr/local/bin \
&& echo 'End minikube stuff...' \
&& echo 'Start kubectl stuff...' \
&& echo 'https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux' \
&& curl -LO https://dl.k8s.io/release/v1.21.2/bin/linux/amd64/kubectl \
&& curl -LO "https://dl.k8s.io/v1.21.2/bin/linux/amd64/kubectl.sha256" \
&& echo "\$(<kubectl.sha256) kubectl" | sha256sum --check \
&& chmod -v +x kubectl \
&& test -d "\$HOME/.local/bin" || mkdir -p "\$HOME"/.local/bin \
&& grep -e 'export PATH=~/.local/bin:"\$PATH"' -i ~/.bashrc || echo 'export PATH=~/.local/bin:"\$PATH"' >> ~/.bashrc \
&& mv ./kubectl ~/.local/bin/kubectl \
&& echo 'End kubectl stuff...' \
&& echo 'Start docker instalation...' \
&& curl -fsSL https://get.docker.com | sudo sh \
&& sudo usermod --append --groups docker "\$USER" \
&& docker --version \
&& echo 'End docker instalation!' \
&& echo 'Start helm instalation...' \
&& curl -sL https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz | tar -zxv \
&& test -d "\$HOME/.local/bin" || mkdir -p "\$HOME"/.local/bin \
&& grep -e 'export PATH=~/.local/bin:"\$PATH"' -i ~/.bashrc || echo 'export PATH=~/.local/bin:"\$PATH"' >> ~/.bashrc \
&& mv linux-amd64/helm "\$HOME"/.local/bin \
&& rm -rv linux-amd64 \
&& echo 'End helm instalation!' \
&& sudo reboot
COMMANDS
} && result/backupCurrentState all-curl-minikube-kubectl-docker-helm \
&& { result/ssh-vm << COMMANDS
minikube start
COMMANDS
} && { result/ssh-vm << COMMANDS
minikube kubectl -- get pods --output=wide
COMMANDS
} && { result/ssh-vm << COMMANDS
minikube start
COMMANDS
} && { result/ssh-vm << COMMANDS
test -d ~/sandbox/sandbox || mkdir -p ~/sandbox/sandbox && cd \$_
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

minikube kubectl -- create -f pod-volume.yaml
minikube kubectl -- get pods | grep -e 'ContainerCreating' || echo 'Error'

until ! minikube kubectl -- get pods | grep -e 'ContainerCreating'
do
    echo "Waiting for minikube kubectl -- get pods --output=wide"
    sleep 1
done
COMMANDS
}
```


```bash
kill -9 $(pidof qemu-system-x86_64) || true \
&& result/resetToBackup all-curl-minikube-kubectl-docker-helm \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
test -d /home/ubuntu/my-volume || mkdir -p /home/ubuntu/my-volume
minikube start --mount --mount-string="/home/ubuntu/my-volume:/minikube-container/some-path"
COMMANDS
} && { result/ssh-vm << COMMANDS
minikube kubectl -- delete pod test-pod-volume
rm -fv pod-volume.yaml.yaml
rm -frv /home/ubuntu/from-container

cd /home/ubuntu/my-volume
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
      path: /minikube-container/some-path
      # this field is optional
      type: DirectoryOrCreate
EOF

minikube kubectl -- create -f pod-volume.yaml | grep -e 'ContainerCreating' || echo 'Error'
minikube kubectl -- get pods | grep -e 'ContainerCreating' || echo 'Error'

until minikube kubectl -- get pods | grep -e 'Running'
do
    echo "Waiting for minikube kubectl -- get pods outputs Running"
    sleep 1
done
minikube kubectl -- get pods

minikube kubectl exec test-pod-volume -- -t -- /bin/sh -c 'touch /home/from-container && ls -ahl /home/from-container'
ls -ahl /home/ubuntu/my-volume/from-container

minikube kubectl -- delete pod test-pod-volume
rm -fv pod-volume.yaml.yaml
rm -frv /home/ubuntu/my-volume/from-container
COMMANDS
} && { result/ssh-vm << COMMANDS
helm create hello-world

helm install hello-world ./hello-world

kubectl get pods

helm ls --all | grep hello-world

helm delete hello-world

COMMANDS
}
```


### Only podman from apt

```bash
create-nix-flake-backup \
&& kill -9 $(pidof qemu-system-x86_64) || true \
&& result/resetToBackup nix-flake \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
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
&& nix \
    profile \
    install \
    nixpkgs#conntrack-tools \
    nixpkgs#minikube \
    nixpkgs#kubectl \
    nixpkgs#kubernetes-helm \
    nixpkgs#ripgrep \
    nixpkgs#tree \
    nixpkgs#which \
&& nix store gc \
&& sudo reboot
COMMANDS
} && result/backupCurrentState from-nix-minikube-helm-kubectl \
&& { result/ssh-vm << COMMANDS
. /etc/os-release \
&& echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_\${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
&& curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_\${VERSION_ID}/Release.key | sudo apt-key add - \
&& sudo apt-get update \
&& sudo apt-get -y install podman \
&& podman --version
COMMANDS
} && result/backupCurrentState from-apt-podman-from-nix-minikube-helm-kubectl \
&& kill -9 $(pidof qemu-system-x86_64) || true \
&& result/resetToBackup from-apt-podman-from-nix-minikube-helm-kubectl \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
podman --version
COMMANDS
}
```

Interesting lines:
```bash
The following NEW packages will be installed:
  catatonit conmon containernetworking-plugins containers-common criu crun dbus-user-session dns-root-data dnsmasq-base fuse-overlayfs fuse3 libfuse3-3 libnet1
  libprotobuf-c1 libprotobuf23 libyajl2 podman podman-machine-cni podman-plugins python3-protobuf slirp4netns uidmap
```

```bash
ssh-vm
```

Point to inject stuff:
```bash
result/resetToBackup from-apt-podman-from-nix-minikube-helm-kubectl \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS
podman --version
COMMANDS
}
```


### WIP

```bash
kill -9 $(pidof qemu-system-x86_64) || true \
&& result/resetToBackup nix-flake \
&& (result/run-vm-kvm < /dev/null &) \
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
&& sudo apt-get -y clean  \
&& sudo rm -rf /var/lib/apt/lists/* \
&& sudo selinux-activate \
&& sudo \
    sed \
    --in-place \
    's/^SELINUX=permissive/SELINUX=disabled/' \
    /etc/selinux/config \
&& echo 'End SELinux instalation!' \
&& echo 'Start a lot of instalation with nix!' \
&& nix \
    profile \
    install \
    github:ES-Nix/podman-rootless/from-nixpkgs \
    nixpkgs#bashInteractive \
    nixpkgs#cni \
    nixpkgs#cni-plugins \
    nixpkgs#conntrack-tools \
    nixpkgs#cri-o \
    nixpkgs#file \
    nixpkgs#findutils \
    nixpkgs#gnumake \
    nixpkgs#jq \
    nixpkgs#kubernetes-helm \
    nixpkgs#minikube \
    nixpkgs#ripgrep \
    nixpkgs#slirp4netns \
    nixpkgs#strace \
    nixpkgs#tree \
    nixpkgs#which \
&& echo 'End instalation with nix!' \
&& sudo ln -fsv /home/ubuntu/.nix-profile/bin/podman /usr/bin/podman \
&& sudo mkdir -p /usr/lib/cni \
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
ssh-vm
```

```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=0 \
gcr.io/k8s-minikube/kicbase:v0.0.26 \
bash \
-c \
'ls -al /'

```


### Magic boilerplate

```bash
kill -9 $(pidof qemu-system-x86_64) || true \
&& result/resetToBackup all-curl-minikube-kubectl-docker-helm \
&& (result/run-vm-kvm < /dev/null &) \
&& { result/ssh-vm << COMMANDS

COMMANDS
}
```



 