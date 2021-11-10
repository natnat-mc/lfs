#!/bin/sh

# create the directory structure for our initrd
mkdir /initrd
for d in bin sbin dev proc sys mnt; do
	mkdir /initrd/$d
done

# add busybox
cd /initrd/bin
cp /busybox-1.34.1/busybox .
chmod 755 busybox
ln -s busybox sh

# add our init script
cd /initrd
cp /initrd-init init
chmod 755 init
ln -s /init sbin/init

# build the archive
cd /initrd
find . | cpio -o -H newc > /initrd.img
zstd < /initrd.img > /initrd.img.zst

