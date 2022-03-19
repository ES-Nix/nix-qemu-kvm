#!/usr/bin/env bash



export VOLUME_MOUNT_PATH="$HOME"/code

export OLD_UID=$(getent passwd "$(id -u)" | cut -f3 -d:)
export NEW_UID=$(stat -c "%u" "$VOLUME_MOUNT_PATH")

export OLD_GID=$(getent group "$(id -g)" | cut -f3 -d:)
export NEW_GID=$(stat -c "%g" "$VOLUME_MOUNT_PATH")

if [ "$OLD_UID" != "$NEW_UID" ]; then
    echo "Changing UID of $(id -un) from $OLD_UID to $NEW_UID"
    #sudo usermod -u "$NEW_UID" -o $(id -un $(id -u))
    sudo find / -xdev -uid "$OLD_UID" -exec chown -hv "$NEW_UID" {} \;
fi

if [ "$OLD_GID" != "$NEW_GID" ]; then
    echo "Changing GID of $(id -un) from $OLD_GID to $NEW_GID"
    #sudo groupmod -g "$NEW_GID" -o $(id -gn $(id -u))
    sudo find / -xdev -group "$OLD_GID" -exec chgrp -hv "$NEW_GID" {} \;
fi

# Do not use the ids here, it does not work!
#sudo chown ubuntu:ubuntu -v "$VOLUME_MOUNT_PATH"

sudo touch -d '1970-01-01 00:00:01' "$HOME"/.Xauthority

sudo su -c "echo 'cd /home/ubuntu/code' >> /home/ubuntu/.profile"

sudo chown -v "$NEW_UID":"$NEW_GID" "$HOME"/. "$HOME"/.Xauthority "$HOME"/.profile


# && sed -i '/^users/s/:[0-9]*:/:978:/g' /etc/group
sudo su -c "sed -i -e 's/^\(ubuntu:[^:]\):[0-9]*:[0-9]*:/\1:${NEW_UID}:${NEW_GID}:/' /etc/passwd && sed -i '/^ubuntu/s/:[0-9]*:/:${NEW_GID}:/g' /etc/group && reboot"

sudo poweroff
