#!/usr/bin/env bash


number_of_arguments="$#"


while [ $number_of_arguments -gt 0 ]; do
  # echo '$# '$#
  case "$1" in
    -b|-backup|--backup)
      BACKUP="$2"
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


BACKUP=${BACKUP:-false}


vm-kill

rm -fv disk.qcow2 userdata.qcow2


if [ nix flake metadata .# 1> /dev/null 2> /dev/null ]; then
  nix build --refresh .#fix-volume-permission
  STORE_PATH_OF_SOURCE_SCRIPT="$(nix eval --raw --refresh .#fix-volume-permission)"
else
  nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#fix-volume-permission
  STORE_PATH_OF_SOURCE_SCRIPT="$(nix eval --raw --refresh github:ES-Nix/nix-qemu-kvm/dev#fix-volume-permission)"
fi


ssh-vm-starts-vm-if-not-running < <(cat "${STORE_PATH_OF_SOURCE_SCRIPT}"/fix-volume-permission.sh)

# The VM should be off at this point.
if [ ! "${BACKUP}" ]; then
  backup-current-state
fi

ssh-vm-starts-vm-if-not-running

# It works, so, we could inject any thing after the ssh-vm
# echo 'Foo'
