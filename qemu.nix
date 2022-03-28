{ pkgs ? import <nixpkgs> { } }:
let
  img_orig = "ubuntu-21.04-server-cloudimg-amd64.img";
  img_orig-20-04 = "ubuntu-20.04-server-cloudimg-amd64.img";

  # It is NOT working!
  user_name = "ubuntu";
  user_password = "b";
in
rec {

  #  image = pkgs.fetchurl {
  #    url = "https://cloud-images.ubuntu.com/releases/hirsute/release-20210817/${img_orig}";
  #    hash = "sha256-q6v8JQ0RIG93mHa42s/o2/u+y6Q2UKGWJiQCQnZA29M=";
  #  };

  image-20-04 = pkgs.fetchurl {
    url = "https://cloud-images.ubuntu.com/releases/focal/release-20201102/${img_orig}";
    hash = "sha256-6/jnDBe5WmGy3K+EajY3yZyvQ0itcUcNOnAf0aTFOUY=";
  };

  image = pkgs.fetchurl {
    url = "https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img";
    hash = "sha256-ZTx7mOjARMH/eQ+SPwZTbOEpfDXYjdsmWcF375tFiqY=";
  };

  config = {
    cpus = 16;
    memory = "1G";
    disk = "5G";
  };

  # This is the cloud-init config
  cloudInit = {
    ssh_authorized_keys = [
      (builtins.readFile ./vagrant.pub)
    ];
    password = "${user_password}";
    chpasswd = {
      list = [
        "root:root"
        "${user_name}:${user_password}"
      ];
      expire = false;
    };
    ssh_pwauth = true;

    #    users = {
    #        name = "user";
    #        passwd = "pwuser";
    #        lock_passwd = "false";
    #        groups = "usergroup";
    #        shell = "${toString "/bin/bash"}";
    #        sudo = "${toString "ALL=(ALL) NOPASSWD:ALL"}";
    #    };

    # Source of magic number msize=262144
    # https://askubuntu.com/questions/548208/sharing-folder-with-vm-through-libvirt-9p-permission-denied/1259833#1259833
    mounts = [
      [ "hostshare" "/home/ubuntu/code" "9p" "defaults,trans=virtio,access=any,version=9p2000.L,cache=none,msize=262144,rw" ]
    ];
  };

  # Generate the initial user data disk. This contains extra configuration
  # for the VM.
  #
  # https://gist.github.com/leogallego/a614c61457ed22cb1d960b32de4a1b01#file-ubuntu-cloud-virtualbox-sh-L44-L57
  # https://stafwag.github.io/blog/blog/2019/03/03/howto-use-centos-cloud-images-with-cloud-init/
  # https://fabianlee.org/2020/02/23/kvm-testing-cloud-init-locally-using-kvm-for-an-ubuntu-cloud-image/
  # https://serverfault.com/questions/369872/run-a-bash-script-after-ec2-instance-boots?rq=1
  userdata = pkgs.runCommand
    "userdata.qcow2"
    { buildInputs = [ pkgs.cloud-utils pkgs.yj pkgs.qemu ]; }
    ''
      {
        echo '#cloud-config'
        echo '${builtins.toJSON cloudInit}' | yj -jy
      } > cloud-init.yaml
      cloud-localds userdata.raw cloud-init.yaml
      qemu-img convert -p -f raw userdata.raw -O qcow2 "$out"
    '';

  runVM = pkgs.writeShellScript "runVM" ''
        #
        # Starts the VM with the given system image
        #
        set -euo pipefail
        image=$1
        userdata=$2
        shift 2

        args=(
          -drive "file=$image,format=qcow2"
          -drive "file=$userdata,format=qcow2"
          -enable-kvm
          -m 18G
          -nographic
          -serial mon:stdio
          -smp 4
          -device "rtl8139,netdev=net0"
          -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:10022-:22"
          -cpu Haswell-noTSX-IBRS,vmx=on
          -cpu host
    #      -fsdev local,security_model=passthrough,id=fsdev0,path="\$(pwd)"
    #      -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
        )

        set -x
        exec ${pkgs.qemu}/bin/qemu-system-x86_64 "''${args[@]}" "$@" >/dev/null 2>&1
  '';

  runVML = pkgs.writeShellScript "runVML" ''
    #
    # Starts the VM with the given system image
    #
    set -euo pipefail
    image=$1
    userdata=$2
    shift 2

    args=(
      -drive "file=$image,format=qcow2"
      -drive "file=$userdata,format=qcow2"
      -m 5G
      -nographic
      -serial mon:stdio
      -smp 4
      -device "rtl8139,netdev=net0"
      -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:10022-:22"
    )

    set -x
    exec ${pkgs.qemu}/bin/qemu-system-x86_64 "''${args[@]}" "$@"
  '';

  vm = pkgs.runCommand "vm" { buildInputs = [ pkgs.qemu ]; }
    ''
      # Make some room on the root image
      cp --reflink=auto "${image}" disk.qcow2
      chmod +w disk.qcow2

      qemu-img resize disk.qcow2 +${config.disk}

      mkdir -p $out/bin

      mv disk.qcow2 $out/disk.qcow2

      ln -s ${userdata} $out/userdata.qcow2

      cat <<WRAP > $out/runVM
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      if [[ ! -f disk.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/disk.qcow2" disk.qcow2
        cp --reflink=auto "$out/userdata.qcow2" userdata.qcow2
        chmod +w disk.qcow2 userdata.qcow2
      fi
      # And finally boot qemu with a bunch of arguments
      args=(
        #
        #-virtfs "local,security_model=none,id=fsdev0,path=\$(pwd),readonly=off,mount_tag=hostshare"
        -fsdev local,security_model=passthrough,id=fsdev0,path="\$(pwd)"
        -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
      )
      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVML} disk.qcow2 userdata.qcow2 "\''${args[@]}" "\$@"
      WRAP
      chmod +x $out/runVM

      cat <<WRAP > $out/bin/run-vm-kvm
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      if [[ ! -f disk.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/disk.qcow2" disk.qcow2
        cp --reflink=auto "$out/userdata.qcow2" userdata.qcow2
        chmod +w disk.qcow2 userdata.qcow2
      fi
      # And finally boot qemu with a bunch of arguments
      args=(
        # Share the nix folder with the guest
        -virtfs "local,security_model=none,id=fsdev0,path=\$PWD,readonly=off,mount_tag=hostshare"
      )
      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVM} disk.qcow2 userdata.qcow2 "\''${args[@]}" "\$@"
      WRAP
      chmod +x $out/bin/run-vm-kvm

      cp --verbose ${sshClient} $out/bin/ssh-vm
      chmod +x $out/bin/ssh-vm
    '';

  vmWithVolumeInHome = pkgs.runCommand "vm-with-volume-in-home" { buildInputs = [ pkgs.qemu ]; }
    ''
      # Make some room on the root image
      cp --reflink=auto "${image}" disk.qcow2
      chmod +w disk.qcow2

      qemu-img resize disk.qcow2 +${config.disk}

      mkdir -p $out/bin

      mv disk.qcow2 $out/disk.qcow2

      ln -s ${userdata} $out/userdata.qcow2

      cat <<WRAP > $out/runVM
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      if [[ ! -f disk.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/disk.qcow2" disk.qcow2
        cp --reflink=auto "$out/userdata.qcow2" userdata.qcow2
        chmod +w disk.qcow2 userdata.qcow2
      fi
      # And finally boot qemu with a bunch of arguments
      args=(
        #
        #-virtfs "local,security_model=none,id=fsdev0,path=\$(pwd),readonly=off,mount_tag=hostshare"
        -fsdev local,security_model=passthrough,id=fsdev0,path="\$(pwd)"
        -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
      )
      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVML} disk.qcow2 userdata.qcow2 "\''${args[@]}" "\$@"
      WRAP
      chmod +x $out/runVM

      cat <<WRAP > $out/bin/run-vm-kvm
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      if [[ ! -f disk.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/disk.qcow2" disk.qcow2
        cp --reflink=auto "$out/userdata.qcow2" userdata.qcow2
        chmod +w disk.qcow2 userdata.qcow2
      fi
      # And finally boot qemu with a bunch of arguments
      args=(
        # Share the nix folder with the guest
        -virtfs "local,security_model=none,id=fsdev0,path=\$PWD,readonly=off,mount_tag=hostshare"
      )
      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVM} disk.qcow2 userdata.qcow2 "\''${args[@]}" "\$@"
      WRAP
      chmod +x $out/bin/run-vm-kvm

      cp --verbose ${sshClient} $out/bin/ssh-vm
      chmod +x $out/bin/ssh-vm
    '';

  sshClient = pkgs.writeShellScript "sshVM" ''
    sshKey=$(mktemp)
    trap 'rm $sshKey' EXIT
    cp ${./vagrant} "$sshKey"
    chmod 0600 "$sshKey"

    until ${pkgs.openssh}/bin/ssh \
      -X \
      -Y \
      -o GlobalKnownHostsFile=/dev/null \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      -o LogLevel=ERROR \
      -i "$sshKey" ${user_name}@127.0.0.1 -p 10022 "$@"; do
      ((c++)) && ((c==60)) && break
      sleep 1
    done

  '';

  # Prepare the VM snapshot for faster resume.
  prepare = pkgs.runCommand "prepare"
    { buildInputs = [ pkgs.qemu (pkgs.python.withPackages (p: [ p.pexpect ])) ]; }
    ''
      export LANG=C.UTF-8
      export LC_ALL=C.UTF-8

      # copy the images to work on them
      cp --reflink=auto "${image}" disk.qcow2
      cp --reflink=auto "${userdata}" userdata.qcow2
      chmod +w disk.qcow2 userdata.qcow2

      # Make some room on the root image
      qemu-img resize disk.qcow2 +64G

      echo 'Run the automated installer'
      python ${./prepare.py} ${runVM} disk.qcow2 userdata.qcow2

      # At this point the disk should have a named snapshot
      qemu-img snapshot -l disk.qcow2 | grep prepare

      mkdir $out
      mv disk.qcow2 userdata.qcow2 $out/

      #
      cat <<WRAP > $out/runVM
      #!${pkgs.stdenv.shell}
      set -euo pipefail

      if [[ ! -f disk.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/disk.qcow2" disk.qcow2
        chmod +w disk.qcow2
      fi

      if [[ ! -f userdata.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/userdata.qcow2" userdata.qcow2
        chmod +w userdata.qcow2
      fi

      # And finally boot qemu with a bunch of arguments
      args=(
        #-loadvm prepare
        #-vga virtio
        # Share the nix folder with the guest
        -virtfs "local,security_model=passthrough,id=fsdev0,path=\$PWD,readonly,mount_tag=hostshare"
        -cpu Haswell-noTSX-IBRS,vmx=on
        -enable-kvm
      )

      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVM} disk.qcow2 userdata.qcow2 "\''${args[@]}"
      WRAP
      chmod +x $out/runVM

    '';

  # Prepare the VM snapshot for faster resume.
  prepare-l = pkgs.runCommand "prepare-l"
    { buildInputs = [ pkgs.qemu (pkgs.python.withPackages (p: [ p.pexpect ])) ]; }
    ''
      export LANG=C.UTF-8
      export LC_ALL=C.UTF-8

      # copy the images to work on them
      cp --reflink=auto "${image}" disk.qcow2
      cp --reflink=auto "${userdata}" userdata.qcow2
      chmod +w disk.qcow2 userdata.qcow2

      # Make some room on the root image
      qemu-img resize disk.qcow2 +64G

      # Run the automated installer
      python ${./prepare.py} ${runVML} disk.qcow2 userdata.qcow2

      # At this point the disk should have a named snapshot
      qemu-img snapshot -l disk.qcow2 | grep prepare

      mkdir $out
      mv disk.qcow2 userdata.qcow2 $out/

      #
      cat <<WRAP > $out/runVML
      #!${pkgs.stdenv.shell}
      set -euo pipefail

      if [[ ! -f disk.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/disk.qcow2" disk.qcow2
        chmod +w disk.qcow2
      fi

      if [[ ! -f userdata.qcow2 ]]; then
        # Setup the VM configuration on boot
        cp --reflink=auto "$out/userdata.qcow2" userdata.qcow2
        chmod +w userdata.qcow2
      fi

      # And finally boot qemu with a bunch of arguments
      args=(
        #-loadvm prepare
        #-vga virtio
        # Share the nix folder with the guest
        -virtfs "local,security_model=passthrough,id=fsdev0,path=\$PWD,readonly,mount_tag=hostshare"
      )

      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVML} disk.qcow2 userdata.qcow2 "\''${args[@]}"
      WRAP
      chmod +x $out/runVML
    '';
}
