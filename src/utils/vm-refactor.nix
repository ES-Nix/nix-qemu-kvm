{ pkgs ?  import <nixpkgs> {}, runVM, run-vm-kvm }:
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
    hash = "sha256-TdO12IoKeue+KiQ4O1/uv879BadFv5t3hgMmPYE4ax8=";
  };

  config = {
    cpus = 16;
    memory = "1G";
    disk = "5G";
  };

  # This is the cloud-init config
  cloudInit = {
    ssh_authorized_keys = [
      ( "${toString ./vagrant.pub}")
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
    { buildInputs = with pkgs; [ cloud-utils yj qemu ]; }
    ''
      {
        echo '#cloud-config'
        echo '${builtins.toJSON cloudInit}' | yj -jy
      } > cloud-init.yaml
      cloud-localds userdata.raw cloud-init.yaml
      qemu-img convert -p -f raw userdata.raw -O qcow2 "$out"
    '';

  vm = pkgs.runCommand "vm" { buildInputs = with pkgs;[ qemu run-vm-kvm ]; }
    ''
      # Make some room on the root image
      cp --reflink=auto "${image}" disk.qcow2
      chmod +w disk.qcow2

      qemu-img resize disk.qcow2 +${config.disk}

      mkdir -p $out/bin

      cp disk.qcow2 $out/disk.qcow2

      ln -s ${userdata} $out/userdata.qcow2

      run-vm-kvm disk.qcow2 "${userdata}"
    '';
}
