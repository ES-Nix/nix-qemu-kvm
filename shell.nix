{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let
  fooHook = stdenv.mkDerivation {
    name = "foo-hook";
    # Setting phases directly is usually discouraged, but in this case we really
    # only need fixupPhase because that's what installs setup hooks
    phases = [ "fixupPhase" ];
    setupHook = writeText "my-setup-hook" ''
            foo() { echo "Foo was called!"; }

            create-nix-flake-backup() {
              kill -9 $(pidof qemu-system-x86_64) || true \
              && result/refresh || nix build .#qemu.vm \
              && (result/run-vm-kvm < /dev/null &) \
              && { result/ssh-vm << COMMANDS
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
                    && nix flake --version \
                    && sudo poweroff
      COMMANDS
      } && kill -9 $(pidof qemu-system-x86_64) || true \
      && rm -fv nix-flake.disk.qcow2.backup nix-flake.userdata.qcow2.backup \
      && result/backupCurrentState nix-flake
            }

            prepares-volume() {

              rm -fr disk.qcow2 userdata.qcow2

              test -f result/run-vm-kvm || nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm

              pidof qemu-system-x86_64 || (result/run-vm-kvm < /dev/null &)

              result/ssh-vm << COMMANDS
              export VOLUME_MOUNT_PATH=/home/ubuntu/code

              touch -d '1970-01-01 00:00:00' /home/ubuntu/.Xauthority

              cat <<WRAP >> "\$HOME"/.profile
              #!/bin/bash

              sudo umount /code
              sudo mount -t 9p \
              -o trans=virtio,access=any,cache=none,version=9p2000.L,cache=none,msize=262144,rw \
              hostshare "\$VOLUME_MOUNT_PATH"

              cd "\$VOLUME_MOUNT_PATH"
      WRAP

              test -d "\$VOLUME_MOUNT_PATH" || sudo mkdir -p "\$VOLUME_MOUNT_PATH"

              sudo stat "\$VOLUME_MOUNT_PATH"
              sudo chown ubuntu: -v "\$VOLUME_MOUNT_PATH"
              sudo stat "\$VOLUME_MOUNT_PATH"

              sudo umount /code

              sudo mount -t 9p \
              -o trans=virtio,access=any,cache=none,version=9p2000.L,cache=none,msize=262144,rw \
              hostshare "\$VOLUME_MOUNT_PATH"

              sudo stat "\$VOLUME_MOUNT_PATH"

              export OLD_UID=\$(getent passwd "\$(id -u)" | cut -f3 -d:)
              export NEW_UID=\$(stat -c "%u" "\$VOLUME_MOUNT_PATH")

              export OLD_GID=\$(getent group "\$(id -g)" | cut -f3 -d:)
              export NEW_GID=\$(stat -c "%g" "\$VOLUME_MOUNT_PATH")

              echo \$OLD_UID
              echo \$NEW_UID
              echo \$OLD_GID
              echo \$NEW_GID

              if [ "\$OLD_UID" != "\$NEW_UID" ]; then
                  echo "Changing UID of \$(id -un) from \$OLD_UID to \$NEW_UID"
                  #sudo usermod -u "\$NEW_UID" -o \$(id -un \$(id -u))
                  sudo find / -xdev -uid "\$OLD_UID" -exec chown -hv "\$NEW_UID" {} \;
              fi

              if [ "\$OLD_GID" != "\$NEW_GID" ]; then
                  echo "Changing GID of \$(id -un) from \$OLD_GID to \$NEW_GID"
                  #sudo groupmod -g "\$NEW_GID" -o \$(id -gn \$(id -u))
                  sudo find / -xdev -group "\$OLD_GID" -exec chgrp -hv "\$NEW_GID" {} \;
              fi

              # Do not use the ids here, it does not work!
              sudo chown ubuntu:ubuntu -v "\$VOLUME_MOUNT_PATH"

              sudo su -c "sed -i -e \"s/^\(ubuntu:[^:]\):[0-9]*:[0-9]*:/\1:\''${NEW_UID}:\''${NEW_GID}:/\" /etc/passwd && sed -i \"/^ubuntu/s/:[0-9]*:/:\''${NEW_GID}:/g\" /etc/group && sed -i \"/^users/s/:[0-9]*:/:978:/g\" /etc/group && reboot"

      COMMANDS
            }

            troubleshoot() {

              { result/ssh-vm << COMMANDS

              pidof qemu-system-x86_64 || (result/run-vm-kvm < /dev/null &)
              export VOLUME_MOUNT_PATH=/home/ubuntu/code
              export OLD_UID=\$(getent passwd "\$(id -u)" | cut -f3 -d:)
              export NEW_UID=\$(stat -c "%u" "\$VOLUME_MOUNT_PATH")

              export OLD_GID=\$(getent group "\$(id -g)" | cut -f3 -d:)
              export NEW_GID=\$(stat -c "%g" "\$VOLUME_MOUNT_PATH")

              echo \$OLD_UID
              echo \$NEW_UID
              echo \$OLD_GID
              echo \$NEW_GID

              sudo su -c "sed -e \"s/^\(ubuntu:[^:]\):[0-9]*:[0-9]*:/\1:\''${NEW_UID}:\''${NEW_GID}:/\" /etc/passwd"

      COMMANDS
            }
            }

            fresh-ssh-vm() {

              backup_name=$1
              if [ -z "$backup_name" ]; then
                kill -9 $(pidof qemu-system-x86_64) 1>/dev/null 2>/dev/null || true \
                && test -d result || nix build .#qemu.vm \
                && result/refresh \
                && (result/run-vm-kvm < /dev/null &) \
                && result/ssh-vm \

                # Note: if `exit 0` is used `nix develop` is exited too.
                return 0
              fi

              kill -9 $(pidof qemu-system-x86_64) 1>/dev/null 2>/dev/null || true \
              && test -d result || nix build .#qemu.vm \
              && result/resetToBackup $backup_name \
              && (result/run-vm-kvm < /dev/null &) \
              && result/ssh-vm
            }

            ssh-vm() {
              pidof qemu-system-x86_64 \
              || test -d result \
              || nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
              && pidof qemu-system-x86_64 \
              || (result/run-vm-kvm < /dev/null &) \
              && result/ssh-vm
            }

            ssh-vm-dev() {
              pidof qemu-system-x86_64 || test -d result || nix build .#qemu.vm \
              && pidof qemu-system-x86_64 || (result/run-vm-kvm < /dev/null &) \
              && result/ssh-vm
            }

            start-minikube() {
              (result/run-vm-kvm < /dev/null &) \
              && { result/ssh-vm << COMMANDS
              test -d /home/ubuntu/my-volume || mkdir -p /home/ubuntu/my-volume
              minikube start --mount --mount-string="/home/ubuntu/my-volume:/minikube-container/some-path"
      COMMANDS
              }
            }

            vm-kill() {
              kill -9 $(pidof qemu-system-x86_64)
            }
            generic-state-tester() {

              backup_name=$1
              if [ -z "$backup_name" ]; then
                backup_name='default';
              fi


              minikube_function=$2
              if [ -z "$minikube_function" ]; then
                minikube_function='start-minikube';
              fi

              kill -9 $(pidof qemu-system-x86_64) || true \
              && result/resetToBackup "$backup_name" \
              && (result/run-vm-kvm < /dev/null &) \
              && ($minikube_function) \
              && { result/ssh-vm << COMMANDS
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
            }
    '';
  };
in
mkShell {
  buildInputs = [
    cloud-utils
    fooHook
    nixpkgs-fmt
    openssh
    qemu
    wget
  ];

  shellHook = ''
    echo 'Hello, you are in the nix shell!'

    alias off-vm-ssh='result/ssh-vm sudo poweroff'
    alias abc='echo ABC'
    alias fssh='fresh-ssh-vm'
    alias svm='ssh-vm'

    # Usefull
    # create-nix-flake-backup
    # rm disk.qcow2 userdata.qcow2
  '';
}
