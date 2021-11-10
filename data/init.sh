#!/bin/busybox sh

# mount some required stuff
mount -t proc proc /proc
mount -t sysfs sys /sys
mdev -s

# display a warm welcome message
clear
echo "Hewwo from initrd!!!"

# start an interactive shell
exec sh -i
