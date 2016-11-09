#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
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
# We can specify make target manually
#
#	make qemu-img
#	make subdir-mips-softmmu
#
# If build errors caused by header files occur, just check if the order of
# `-Idir` is correct and we do not incorrectly include header files from sys
# directories first
#
# - The QEMU build system architecture, docs/build-system.txt
#
PKG_NAME=qemu
PKG_VERSION=2.7.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://wiki.qemu-project.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=08d4d06d1cb598efecd796137f4844ab
PKG_DEPENDS='bzip2 curl gnutls libjpeg-turbo libpng lzo ncurses nettle zlib'

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libaio"
fi

#
# Others targets can be found in help text for `--target-list` option from
# output of `./configure --help`
#
TARGETS=
TARGETS="$TARGETS i386-softmmu x86_64-softmmu"
TARGETS="$TARGETS mips-softmmu mipsel-softmmu mips64-softmmu mips64el-softmmu"
TARGETS="$TARGETS arm-softmmu"
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
TARGETS="$TARGETS i386-linux-user"
TARGETS="$TARGETS mips-linux-user mipsn32-linux-user mips64-linux-user"
TARGETS="$TARGETS arm-linux-user aarch64-linux-user"

CONFIGURE_VARS="$CONFIGURE_VARS		\\
	QEMU_CFLAGS='$EXTRA_CFLAGS'		\\
"
CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-gnutls					\\
	--enable-nettle					\\
	--enable-curses					\\
	--enable-lzo					\\
	--enable-bzip2					\\
	--enable-vnc					\\
	--enable-vnc-jpeg				\\
	--enable-vnc-png				\\
	--target-list='$TARGETS'		\\
"
MAKE_VARS="V=s"

install_post() {
	cat <<EOF

To use qemu-bridge-helper, appropriate permission bits need to be set

	sudo chown root:root $INSTALL_PREFIX/libexec/qemu-bridge-helper
	sudo chmod u+s $INSTALL_PREFIX/libexec/qemu-bridge-helper

EOF
}
