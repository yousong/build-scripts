#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# @curl is required for curl block driver
# @gnutls is required for vnc through websocket
#
# When building on debian, the following additional packages may also be required.
#
#	pkg-config - manage compile and link flags for libraries
#	libglib2.0-dev - Development files for the GLib library
#	libpixman-1-dev - pixel-manipulation library for X and cairo (development files)
#
# When buliding on centos,
#
#	glib2-devel
#
# VirtFS support is only available on linux and libcap is required by
# fsdev/virtfs-proxy-helper) and {get,set}xattr provided either by libc or
# libxattr are also required
#
#	libcap-dev - development libraries and header files for libcap2
#	libattr1-dev - Extended attribute static libraries and headers
#
# VirGL requires QEMU ui supporting OpenGL: have_virgl = display_opengl
#
# Spice support requires the following packages. In addition, SPICE OpenGL
# support requires spice-server version of at 0.13.1 while CentOS 7.4 provides
# 0.12.8 by default.
#
#	spice-server-devel spice-protocol
#
# According to QEMU code, SPIECE GL support is local-only for now (as of
# version 2.11.1) and incompatible with -spice port/tls-port
#
# We can specify make target manually
#
#	make qemu-img
#	make mips-softmmu/all
#
# If build errors caused by header files occur, just check if the order of
# `-Idir` is correct and we do not incorrectly include header files from sys
# directories first
#
# - The QEMU build system architecture, docs/build-system.txt
#
PKG_NAME=qemu
PKG_VERSION=4.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://download.qemu.org/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=cdf2b5ca52b9abac9bacb5842fa420f8

# Add slirp when we can build dynamic library
PKG_DEPENDS="$PKG_DEPENDS bzip2 capstone curl dtc gnutls libjpeg-turbo libpng"
PKG_DEPENDS="$PKG_DEPENDS lzo ncurses nettle pixman virglrenderer zlib"

. "$PWD/env.sh"

# build system of qemu knows how to strip those compiled components
STRIP=()

# libcap-ng is an optional dependency for qemu-bridge-helper to drop privileges
# but preserving CAP_NET_ADMIN
#
# libcap is required by fsdev-proxy-helper
if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libaio libcap libcap-ng"
fi

#
# Others targets can be found in help text for `--target-list` option from
# output of `./configure --help`
#
TARGETS+=( i386-softmmu )
TARGETS+=( x86_64-softmmu )

TARGETS+=( mips-softmmu )
TARGETS+=( mipsel-softmmu )
TARGETS+=( mips64-softmmu )
TARGETS+=( mips64el-softmmu )

TARGETS+=( arm-softmmu )
TARGETS+=( aarch64-softmmu )

TARGETS+=( riscv64-softmmu )

#
# Things to keep in mind when using user mode emulation with dynamically linked
# binaries
#
#  - Where to find the dynamic linker (elf interpreter).  Check the default
#    path with `readelf -l <bin>` and use -L to add path prefix
#  - Where to find dynamic libraries.  If no rpath is set, try setting
#    LD_LIBRARY_PATH with -E option
#
# Example
#
#	prefix=$HOME/mips-bs-linux-gnu_gcc-6.2.0_glibc-2.24_binutils-2.27
#	qemu-mips -L "$prefix" -E LD_LIBRARY_PATH="$prefix' a.out
#
# Refs
#
#  - https://wiki.debian.org/QemuUserEmulation
#  - https://github.com/qemu/qemu/blob/master/scripts/qemu-binfmt-conf.sh
#
# qemu-mipsn32 is buggy and is also confirmed by
# https://lists.gnu.org/archive/html/qemu-devel/2016-10/msg01939.html
#
# TODO
#
# 1. Play with linux-user docker targets.
#
#    See Changelog/2.7 for how to use it.  See tests/docker/Makefile.include
#    for details of implementation and available targets
#
if os_is_linux; then
	TARGETS+=( i386-linux-user)
	TARGETS+=( mips-linux-user mipsn32-linux-user mips64-linux-user)
	TARGETS+=( arm-linux-user aarch64-linux-user)
fi

if os_is_darwin; then
	# - _XOPEN_SOURCE: required to enable NCURSES_WIDECHAR
	# - _DARWIN_C_SOURCE: required to make SIGIO availabe (see
	#   /usr/include/sys/signal.h)
	#
	# Setting MACOSX_DEPLOYMENT_TARGET to version >=10.5 as said in compat(5)
	# is not enough.
	EXTRA_CPPFLAGS+=(
		-D_DARWIN_C_SOURCE
		-D_XOPEN_SOURCE=600
	)
	EXTRA_CFLAGS+=(
		-D_DARWIN_C_SOURCE
		-D_XOPEN_SOURCE=600
	)
fi
CONFIGURE_ARGS+=(
	--enable-gnutls
	--enable-nettle
	--enable-curses
	--enable-lzo
	--enable-bzip2
	--enable-virglrenderer
	--enable-vnc
	--enable-vnc-jpeg
	--enable-vnc-png
	--enable-capstone=system
	--target-list="${TARGETS[*]}"
	--extra-cflags="${EXTRA_CFLAGS[*]}"
	--extra-cxxflags="${EXTRA_CXXFLAGS[*]}"
	--extra-ldflags="${EXTRA_LDFLAGS[*]}"
)
MAKE_VARS+=(
	V=s
)

install_post() {
	local helper="$INSTALL_PREFIX/libexec/qemu-bridge-helper"

	if [ -x "$helper" ]; then
		cat <<EOF

To use qemu-bridge-helper, appropriate permission bits need to be set

	sudo chown root:root $helper
	sudo chmod u+s $helper

EOF
	fi
}
