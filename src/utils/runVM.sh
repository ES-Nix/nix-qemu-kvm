#!/usr/bin/env bash


#
# Starts the VM with the given system image
#
set -euo pipefail


image=$1
userdata=$2
shift 2

# echo $image
# echo $userdata

# https://github.com/kubernetes/minikube/issues/3634#issuecomment-495015355
# https://support.solus.io/hc/en-us/articles/360024682131-Unable-to-boot-KVM-VPS-in-SolusVM-cannot-set-up-guest-memory-pc-ram-Cannot-allocate-memory
args=(
  -drive "file=$image,format=qcow2"
  -drive "file=$userdata,format=qcow2"
  -enable-kvm
  -m 5G
  -nographic
  -serial mon:stdio
  -smp 4
  -device "rtl8139,netdev=net0"
  -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:10022-:22"
  -cpu Haswell-noTSX-IBRS,vmx=on
  -cpu host
  # -fsdev local,security_model=passthrough,id=fsdev0,path="\$(pwd)"
  # -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
)

set -x
exec qemu-kvm "${args[@]}" "$@"