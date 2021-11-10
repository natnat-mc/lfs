# build our kernel
# we need debian for this because somehow alpine fails to compile it
FROM debian:11 AS build-kernel
RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends xz-utils ca-certificates build-essential flex bison libssl-dev openssl zstd bc perl libelf-dev -y
COPY vendor/linux.tar.xz /linux.tar.xz
COPY config.linux /linux-out/.config
RUN export ARCH=x86_64 O=/linux-out \
	&& mkdir /linux \
	&& cd /linux \
	&& tar xJf /linux.tar.xz --strip-components 1 \
	&& make prepare O=$O ARCH=$ARCH \
	&& make -j24 O=$O ARCH=$ARCH \
	&& make -j24 headers O=$O ARCH=$ARCH \
	&& make -j24 bzImage O=$O ARCH=$ARCH

# build our initrd
# we do this on alpine to use musl instead of glibc, to get a smaller initrd size
FROM alpine:3.14 AS build-initrd
RUN apk add --no-cache gcc make zstd cpio musl-dev
COPY vendor/busybox.tar.bz2 /busybox.tar.bz2
COPY config.busybox.initrd /busybox/.config
COPY --from=build-kernel /linux-out/usr/include /usr/include
RUN cd /busybox \
	&& tar xjf /busybox.tar.bz2 --strip-components 1 \
	&& make -j24
COPY init.sh /initrd-init
COPY mkinitrd.sh /mkinitrd
RUN chmod +x /mkinitrd \
	&& /mkinitrd

# build a docker image which is our system so we can `docker cp` from it
FROM scratch AS system
COPY --from=build-kernel /linux-out/usr/include /out/usr/include
COPY --from=build-kernel /linux-out/arch/x86/boot/bzImage /out/boot/vmlinuz
COPY --from=build-initrd /initrd.img.zst /out/boot/initrd.img.zst

# we need this for now to have something to run a container with
COPY --from=build-initrd /busybox/busybox /bin/true
