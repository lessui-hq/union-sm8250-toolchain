FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt -y update && apt -y install \
	autoconf \
	bc \
	build-essential \
	bzip2 \
	bzr \
	cmake \
	cmake-curses-gui \
	cpio \
	git \
	libncurses5-dev \
	locales \
	make \
	rsync \
	scons \
	tree \
	unzip \
	wget \
  && rm -rf /var/lib/apt/lists/*

# Download and extract LessOS RK3566 toolchain
WORKDIR /opt
RUN wget https://github.com/lessui-hq/union-rk3566-toolchain/releases/download/lessos-toolchain-0.1/lessos-toolchain-RK3566.tar.gz && \
    tar xzf lessos-toolchain-RK3566.tar.gz && \
    mv build.LessOS-RK3566.aarch64/toolchain . && \
    rm -rf build.LessOS-RK3566.aarch64 lessos-toolchain-RK3566.tar.gz && \
    # Replace ccache wrapper scripts with direct symlinks to real binaries
    for f in /opt/toolchain/bin/aarch64-rocknix-linux-gnu-*; do \
        if [ -f "$f" ] && head -1 "$f" 2>/dev/null | grep -q '^#!/bin/sh'; then \
            real_bin=$(grep -o '/[^ ]*aarch64-rocknix-linux-gnu-[^ ]*' "$f" | tail -1 | sed 's|.*/toolchain|/opt/toolchain|'); \
            if [ -n "$real_bin" ] && [ -f "$real_bin" ]; then \
                rm "$f" && ln -s "$real_bin" "$f"; \
            fi; \
        fi; \
    done && \
    # Fix all symlinks with hardcoded build paths
    find /opt/toolchain -type l | while read link; do \
        target=$(readlink "$link"); \
        if echo "$target" | grep -q "/home/nchapman/Code/LessOS/build.LessOS-RK3566.aarch64/toolchain"; then \
            new_target=$(echo "$target" | sed 's|/home/nchapman/Code/LessOS/build.LessOS-RK3566.aarch64/toolchain|/opt/toolchain|g'); \
            rm "$link" && ln -s "$new_target" "$link"; \
        fi; \
    done && \
    # Remove toolchain make/gmake to avoid jobserver incompatibility with system make
    rm -f /opt/toolchain/bin/make /opt/toolchain/bin/gmake

# Setup workspace
RUN mkdir -p /root/workspace
VOLUME /root/workspace
WORKDIR /root/workspace

# Configure toolchain environment
ENV PATH="/opt/toolchain/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/toolchain/x86_64-linux-gnu/aarch64-rocknix-linux-gnu/lib:/opt/toolchain/lib"
ENV CROSS_COMPILE=/opt/toolchain/bin/aarch64-rocknix-linux-gnu-
ENV SYSROOT=/opt/toolchain/aarch64-rocknix-linux-gnu/sysroot
ENV PREFIX=/opt/toolchain/aarch64-rocknix-linux-gnu/sysroot/usr
ENV UNION_PLATFORM=rk3566

# pkg-config for cross-compilation (finds SDL2, librga, etc.)
ENV PKG_CONFIG_PATH=/opt/toolchain/aarch64-rocknix-linux-gnu/sysroot/usr/lib/pkgconfig
ENV PKG_CONFIG_LIBDIR=/opt/toolchain/aarch64-rocknix-linux-gnu/sysroot/usr/lib/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=/opt/toolchain/aarch64-rocknix-linux-gnu/sysroot

# Linker flags for finding shared library dependencies in sysroot
ENV LDFLAGS="-L${SYSROOT}/usr/lib -Wl,-rpath-link=${SYSROOT}/usr/lib"
ENV CFLAGS="-I${SYSROOT}/usr/include"

CMD ["/bin/bash"]