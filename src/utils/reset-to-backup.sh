#!/usr/bin/env bash


# set -euo pipefail

backup_name=$1
if [ -z "$backup_name" ]; then
  backup_name='default';
fi

# https://serverfault.com/questions/665335/what-is-fastest-way-to-copy-a-sparse-file-what-method-results-in-the-smallest-f
# cp --verbose "$backup_name".disk.qcow2.backup disk.qcow2
# cp --verbose "$backup_name".userdata.qcow2.backup userdata.qcow2

echo 'Start reset to backup...'
dd if="$backup_name".disk.qcow2.backup of=disk.qcow2 iflag=direct oflag=direct bs=4M conv=sparse
dd if="$backup_name".userdata.qcow2.backup of=userdata.qcow2 iflag=direct oflag=direct bs=4M conv=sparse
echo 'End reset to backup...'