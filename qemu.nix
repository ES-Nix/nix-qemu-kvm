{ pkgs ?  import <nixpkgs> {} }:
let
  img_orig = "ubuntu-20.04-server-cloudimg-amd64.img";

  # It is NOT working!
  user_name = "ubuntu";
  user_password = "b";
in
rec {
  #image = pkgs.fetchurl {
  #  url = "https://cloud-images.ubuntu.com/releases/focal/release-20201102/${img_orig}";
  #  hash = "sha256-6/jnDBe5WmGy3K+EajY3yZyvQ0itcUcNOnAf0aTFOUY=";
  #};

  image = pkgs.fetchurl {
    url = "https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img";
    hash = "sha256-mG4TemnY7HWXUnUEVPGbwSRB0b5xwEKqIwXsXS5t2IQ=";
  };

  config = {
    cpus = 16;
    memory = "2G";
    disk = "8G";
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

    mounts = [
      [ "hostshare" "/mnt" "9p" "defaults,trans=virtio,version=9p2000.L" ]
    ];
  };

  # Generate the initial user data disk. This contains extra configuration
  # for the VM.
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
      -m 2G
      -nographic
      -serial mon:stdio
      -smp 2
      -device "rtl8139,netdev=net0"
      -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:10022-:22"
    )

    set -x
    exec ${pkgs.qemu}/bin/qemu-system-x86_64 "''${args[@]}" "$@"
  '';

  sshClient = pkgs.writeShellScript "sshVM" ''
    sshKey=$(mktemp)
    trap 'rm $sshKey' EXIT
    cp ${./vagrant} "$sshKey"
    chmod 0600 "$sshKey"
    ssh -i "$sshKey" ${user_name}@127.0.0.1 -p 10022 "$@"
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

      # Run the automated installer
      python ${./prepare.py} ${runVM} disk.qcow2 userdata.qcow2

      # At this point the disk should have a named snapshot
      qemu-img snapshot -l disk.qcow2 | grep prepare

      mkdir $out
      mv disk.qcow2 userdata.qcow2 $out/

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
      )

      echo "Starting VM."
      echo "To login: ubuntu / ubuntu"
      echo "To quit: type 'Ctrl+a c' then 'quit'"
      echo "Press enter in a few seconds"
      exec ${runVM} disk.qcow2 userdata.qcow2 "\''${args[@]}"
      WRAP
      chmod +x $out/runVM

      cat <<WRAP > $out/backupCurrentState
      #!${pkgs.stdenv.shell}
      set -euo pipefail

      cp --verbose disk.qcow2 disk.qcow2.backup
      cp --verbose userdata.qcow2 userdata.qcow2.backup

      WRAP
      chmod +x $out/backupCurrentState

      cat <<WRAP > $out/resetToBackup
      #!${pkgs.stdenv.shell}
      set -euo pipefail

      cp --verbose disk.qcow2.backup disk.qcow2
      cp --verbose userdata.qcow2.backup userdata.qcow2

      WRAP
      chmod +x $out/resetToBackup

      cat <<WRAP > $out/refresh
      #!${pkgs.stdenv.shell}
      set -euo pipefail

      rm --force --verbose disk.qcow2 userdata.qcow2

      WRAP
      chmod +x $out/refresh

    '';
  }
