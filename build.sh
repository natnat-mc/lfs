#!/bin/sh

echo "Checking vendored dependencies"
[ -d vendor ] || mkdir vendor

if ! [ -f vendor/linux.tar.xz ]; then
	echo "Downloading Linux sources"
	curl -L https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.1.tar.xz > vendor/linux.tar.xz
fi

if ! [ -f vendor/busybox.tar.bz2 ]; then
	echo "Downloading busybox sources"
	curl -L https://busybox.net/downloads/busybox-1.34.1.tar.bz2 > vendor/busybox.tar.bz2
fi


echo "Building system"
docker build -t lfs:dev .
docker rm lfs
docker run -it --name lfs lfs:dev /bin/true

echo "Copying system outside of docker"
rm -rf out
docker cp lfs:/out out

echo "Done!"
