#!/usr/bin/env bash


store_disk=$1
store_userdata=$2
shift 2

# set -euo pipefail

# if [[ ! -f disk.qcow2 ]]; then
# Setup the VM configuration on boot
cp --reflink=auto $store_disk disk.qcow2
cp --reflink=auto $store_userdata userdata.qcow2
chmod +w disk.qcow2 userdata.qcow2
# fi

# And finally boot qemu with a bunch of arguments
args=(
  # Share the nix folder with the guest
  # -virtfs "local,security_model=none,id=fsdev0,path=\$PWD,readonly=off,mount_tag=hostshare"
)
echo "Starting VM."
echo "To login: ubuntu / ubuntu"
echo "To quit: type 'Ctrl+a c' then 'quit'"
echo "Press enter in a few seconds"

# type runVM

ls -al
exec -a runVM disk.qcow2 userdata.qcow2 "${args[@]}" "$@"
