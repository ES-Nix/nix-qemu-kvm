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

# It could be a function in the future.
if nix flake metadata .# 1> /dev/null 2> /dev/null ; then

  nix build --refresh .#install-nix --no-link
  STORE_PATH_OF_INSTALL_NIX="$(nix eval --raw --refresh .#install-nix)"
else

  nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#install-nix --no-link
  STORE_PATH_OF_INSTALL_NIX="$(nix eval --raw --refresh github:ES-Nix/nix-qemu-kvm/dev#install-nix)"
fi

ssh-vm-starts-vm-if-not-running < <(cat "${STORE_PATH_OF_INSTALL_NIX}"/install-nix.sh)


if [ "${BACKUP}" ]; then

  # We must test if the VM is off
  # After one test, it is clear that
  # it slows a lot the script, so, hack...
  # I have put the sudo poweroff in the
  # end of the insta
#  { ssh-vm <<COMMANDS
#    sudo poweroff
#COMMANDS
#  } && echo 'End!'

  # Well, if it works it will be the faster one!
  # The only problem is if it will corrupt some how the file system.
  vm-kill
  backup-current-state
fi


ssh-vm-starts-vm-if-not-running
