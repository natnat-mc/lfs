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

if ! [ -f vendor/musl.tar.gz ]; then
	echo "Downloading musl sources"
	curl -L http://musl.libc.org/releases/musl-1.2.2.tar.gz > vendor/musl.tar.gz
fi

if ! [ -f vendor/gawk.tar.xz ]; then
	echo "Downloading awk sources"
	curl -L https://ftp.gnu.org/gnu/gawk/gawk-5.1.1.tar.xz > vendor/gawk.tar.xz
fi

if ! [ -f vendor/make.tar.gz ]; then
	echo "Downloading make sources"
	curl -L https://ftp.gnu.org/gnu/make/make-4.3.tar.gz > vendor/make.tar.gz
fi

if ! [ -f vendor/perl.tar.gz ]; then
	echo "Downloading perl sources"
	curl -L https://github.com/Perl/perl5/archive/refs/tags/v5.34.0.tar.gz > vendor/perl.tar.gz
fi

if ! [ -f vendor/binutils.tar.xz ]; then
	echo "Downloading binutils sources"
	curl -L http://mirrors.kernel.org/gnu/binutils/binutils-2.37.tar.xz > vendor/binutils.tar.xz
fi
