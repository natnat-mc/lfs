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

# build our build base we'll use to bootstrap ourselves
# we do this on alpine because that's what i prefer using
FROM alpine:3.14 AS build-buildbase
RUN apk add --no-cache gcc make musl-dev
COPY vendor/busybox.tar.bz2 /busybox.tar.bz2
COPY config.busybox.buildbase /busybox/.config
COPY --from=build-kernel /linux-out/usr/include /usr/include
RUN cd /busybox \
	&& tar xjf /busybox.tar.bz2 --strip-components 1 \
	&& make -j24 \
	&& rm -rf /busybox.tar.bz2
COPY vendor/musl.tar.gz /musl.tar.gz
RUN mkdir /musl \
	&& cd musl \
	&& tar xzf /musl.tar.gz --strip-components 1 \
	&& ./configure --prefix=/ \
	&& make -j24 \
	&& rm -rf /musl.tar.gz
COPY vendor/gawk.tar.xz /gawk.tar.xz
RUN mkdir /gawk \
	&& cd gawk \
	&& tar xJf /gawk.tar.xz --strip-components 1 \
	&& export LDFLAGS=-static \
	&& ./configure --prefix=/ LDFLAGS=$LDFLAGS \
	&& make -j24 LDFLAGS=$LDFLAGS \
	&& rm -rf /gawk.tar.xz
COPY vendor/make.tar.gz /make.tar.gz
RUN mkdir /make \
	&& cd make \
	&& tar xzf /make.tar.gz --strip-components 1 \
	&& export LDFLAGS=-static \
	&& ./configure --prefix=/ LDFLAGS=$LDFLAGS \
	&& make -j24 LDFLAGS=$LDFLAGS \
	&& rm -rf /make.tar.gz
COPY vendor/perl.tar.gz /perl.tar.gz
RUN mkdir /perl \
	&& cd perl \
	&& tar xzf /perl.tar.gz --strip-components 1 \
	&& ./Configure -des \
		-Dldflags='-static' \
		-Uusedl \
		-Dprefix=/opt/perl \
		-Dvendorprefix=/opt/perl \
		-Dvendorlib=/opt/perl/vendor_perl \
		-Dvendorarch=/opt/perl/vendor_perl \
		-Dsiteprefix=/opt/perl \
		-Dsitelib=/opt/perl/site_perl \
		-Dsitearch=/opt/perl/site_perl \
		-Dlocincpth=' ' \
		-Duselargefiles \
		-Dusethreads \
		-Duseshrplib \
		-Dd_semctl_semun \
		-Dcf_by='lfs' \
		-Ud_csh \
		-Dusenm \
	&& make -j24 \
	&& make install \
	&& rm -rf /perl.tar.gz

# build a docker image which is our system so we can `docker cp` from it
FROM scratch AS system
COPY --from=build-kernel /linux-out/usr/include /out/usr/include
COPY --from=build-kernel /linux-out/arch/x86/boot/bzImage /out/boot/vmlinuz
COPY --from=build-initrd /initrd.img.zst /out/boot/initrd.img.zst

# we need this for now to have something to run a container with
COPY --from=build-buildbase /busybox/busybox /bin/true

# test stuff
COPY --from=build-buildbase /busybox/busybox out/buildbase/bin/busybox
COPY --from=build-buildbase /musl/lib out/buildbase/lib
COPY --from=build-buildbase /musl/include out/buildbase/include
COPY --from=build-buildbase /musl/obj/include/* out/buildbase/include/
COPY --from=build-buildbase /gawk/gawk out/buildbase/bin/gawk
COPY --from=build-buildbase /make/make out/buildbase/bin/make
COPY --from=build-buildbase /perl/perl out/buildbase/bin/perl
COPY --from=build-buildbase /opt out/buildbase/opt
