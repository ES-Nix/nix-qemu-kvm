#!/usr/bin/env bash


SSH_KEY=$(mktemp)
trap 'rm $SSH_KEY' EXIT
cp ./vagrant "$SSH_KEY"
chmod 0600 "$SSH_KEY"

until ssh \
  -X \
  -Y \
  -o GlobalKnownHostsFile=/dev/null \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o LogLevel=ERROR \
  -i "$SSH_KEY" \
  ubuntu@127.0.0.1 \
  -p 10022 \
  "$@"; do
  ((c++)) && ((c==60)) && break
  sleep 1
done
