#!/usr/bin/env bash



number_of_arguments="$#"

while [ $number_of_arguments -gt 0 ]; do
  # echo '$# '$#
  case "$1" in
    -dn|-disk-name|--disk-name)
      DISK_NAME="$2"
      ;;
    -ud|-userdata-name|--userdata-name)
      USERDATA_NAME="$2"
      ;;
    -sdn|-store-disk-name|--store-disk-name)
      STORE_DISK_NAME="$2"
      ;;
    -sud|-store-userdata-name|--store-userdata-name)
      STORE_USERDATA_NAME="$2"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      echo "$1"
      echo "$2"
      should_shift='false'
      # exit 1
  esac

  if [ "$should_shift" == 'true' ]; then
    shift
    shift
  fi

  number_of_arguments="$((number_of_arguments - 1))"
done


DISK_NAME=${DISK_NAME:-disk.qcow2}
USERDATA_NAME=${USERDATA_NAME:-userdata.qcow2}

STORE_DISK_NAME=${STORE_DISK_NAME:-store-disk-name}
STORE_USERDATA_NAME=${STORE_USERDATA_NAME:-store-userdata-name}

# echo "${STORE_DISK_NAME}"
# echo "${STORE_USERDATA_NAME}"

if [[ ! -f "${DISK_NAME}" ]]; then
  # Setup the VM configuration on boot
  dd if="${STORE_DISK_NAME}" of="${DISK_NAME}" iflag=direct oflag=direct bs=4M conv=sparse
  # cp --reflink=auto "${STORE_DISK_NAME}" "${DISK_NAME}"
  chmod +w "${DISK_NAME}"
fi

if [[ ! -f "${USERDATA_NAME}" ]]; then
  # Setup the VM configuration on boot
  # Hunting a bug, maybe cp --reflink=auto is bring to me an not desired behavior.
  # Even when all disks are removed, I still hit some sort of cached disk.
  dd if="${STORE_USERDATA_NAME}" of="${USERDATA_NAME}" iflag=direct oflag=direct bs=4M conv=sparse
  # cp --reflink=auto "${STORE_USERDATA_NAME}" "${USERDATA_NAME}"
  chmod +w "${USERDATA_NAME}"
fi

# And finally boot qemu with a bunch of arguments
args=(
  # Share the nix folder with the guest
  -virtfs "local,security_model=none,id=fsdev0,path=$(pwd),readonly=off,mount_tag=hostshare"
)
echo "Starting VM."
echo "To login: ubuntu / ubuntu"
echo "To quit: type 'Ctrl+a c' then 'quit'"
echo "Press enter in a few seconds"

# type runVM

# ls -al

runVM-with-volume "${DISK_NAME}" "${USERDATA_NAME}" "${args[@]}" "$@"


#search_for() {
#  zcat /proc/config.gz | rg $1
#}
#
#search_for CONFIG_NET_9P
