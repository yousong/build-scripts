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
PKG_NAME=qemu
PKG_VERSION=2.6.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://wiki.qemu-project.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6a183b192018192943b6781e1bb9b72f
PKG_DEPENDS='bzip2 curl gnutls libjpeg-turbo libpng lzo ncurses nettle zlib'

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libaio"
fi

#
# Others targets can be found in help text for `--target-list` option from
# output of `./configure --help`
#
TARGETS="i386-softmmu x86_64-softmmu mipsel-softmmu mips-softmmu mips64el-softmmu mips64-softmmu arm-softmmu"

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
