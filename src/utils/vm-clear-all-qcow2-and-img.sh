#!/usr/bin/env bash


number_of_arguments="$#"

while [ $number_of_arguments -gt 0 ]; do
  # echo '$# '$#
  case "$1" in
    -rb|-remove-all-backups|--remove-all-backups)
      REMOVE_ALL_BACKUPS="$2"
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


REMOVE_ALL_BACKUPS=${REMOVE_ALL_BACKUPS:-false}


# It is not so robust, it relies in the way
# the files are named.
if "${REMOVE_ALL_BACKUPS}"; then
  rm -fv *.qcow2* *.img*
else
  rm -fv *.qcow2 *.img
fi
