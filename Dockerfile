# build our kernel
# we need debian for this because somehow alpine fails to compile it
FROM debian:11 AS build-kernel
RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends curl xz-utils ca-certificates build-essential flex bison libssl-dev openssl zstd bc perl libelf-dev -y
RUN curl -sL "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.1.tar.xz" | tar xJ
COPY config.linux /linux-out/.config
RUN export ARCH=x86_64 O=/linux-out \
	&& cd /linux-5.15.1 \
	&& make prepare O=$O ARCH=$ARCH \
	&& make -j24 O=$O ARCH=$ARCH
RUN export ARCH=x86_64 O=/linux-out \
	&& cd /linux-5.15.1 \
	&& make headers O=$O ARCH=$ARCH \
	&& make bzImage O=$O ARCH=$ARCH

# build our initrd
# we do this on alpine to use musl instead of glibc, to get a smaller initrd size
FROM alpine:3.14 AS build-initrd
RUN apk add --no-cache curl gcc make zstd cpio musl-dev
RUN curl -sL "https://busybox.net/downloads/busybox-1.34.1.tar.bz2" | tar xj
COPY config.busybox /busybox-1.34.1/.config
COPY --from=build-kernel /linux-out/usr/include /usr/include
RUN cd /busybox-1.34.1 \
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
COPY --from=build-initrd /busybox-1.34.1/busybox /bin/true
