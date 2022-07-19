#!/usr/bin/env bash


# set -x

vm-kill

rm -fv disk.qcow2 userdata.qcow2

ssh-vm-starts-vm-if-not-running

# It works, so, we could inject any thing after the ssh-vm
# echo 'Foo'
