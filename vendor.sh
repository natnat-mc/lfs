#!/bin/sh

echo "Checking vendored dependencies"
[ -d vendor ] || mkdir vendor

vendor() {
	printf "Checking for %s\n" "$1"
	if ! [ -f vendor/"$2" ]; then
		printf "Downloading %s\n" "$1"
		curl -L "$3" > vendor/"$2"
		printf "Downloaded %s\n" "$1"
	else
		printf "Already downloaded\n"
	fi
}

vendor linux	linux.tar.xz	https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.1.tar.xz
vendor busybox	busybox.tar.bz2	https://busybox.net/downloads/busybox-1.34.1.tar.bz2
vendor musl		musl.tar.gz		http://musl.libc.org/releases/musl-1.2.2.tar.gz
vendor gawk		gawk.tar.gz		https://ftp.gnu.org/gnu/gawk/gawk-5.1.1.tar.xz
vendor make		make.tar.gz		https://ftp.gnu.org/gnu/make/make-4.3.tar.gz
vendor perl		perl.tar.gz		https://github.com/Perl/perl5/archive/refs/tags/v5.34.0.tar.gz
vendor binutils	binutils.tar.xz	http://mirrors.kernel.org/gnu/binutils/binutils-2.37.tar.xz
vendor libmpfr	libmpfr.tar.xz	https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.xz
vendor libmpc	libmpc.tar.gz	https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
vendor libgmp	libgmp.tar.xz	https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz
vendor gcc		gcc.tar.xz		http://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.xz

echo "Vendoring complete"
