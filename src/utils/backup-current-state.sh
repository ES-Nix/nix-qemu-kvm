#!/usr/bin/env bash


# set -euo pipefail


backup_name="${1:-default}"

# cp --verbose disk.qcow2 "\$backup_name".disk.qcow2.backup
# cp --verbose userdata.qcow2 "\$backup_name".userdata.qcow2.backup

echo 'Start backup named: '"$backup_name"

dd if=disk.qcow2 of="${backup_name}".disk.qcow2.backup iflag=direct oflag=direct bs=4M conv=sparse
dd if=userdata.qcow2 of="${backup_name}".userdata.qcow2.backup iflag=direct oflag=direct bs=4M conv=sparse

echo 'End backup...'"$backup_name"
