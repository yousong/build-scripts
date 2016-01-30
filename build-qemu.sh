#!/bin/sh -e
#
# @curl is required for curl block driver
#
PKG_NAME=qemu
PKG_VERSION=2.5.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://wiki.qemu-project.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f469f2330bbe76e3e39db10e9ac4f8db
PKG_DEPENDS='zlib curl ncurses'

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libaio"
fi

# Others targets can be found in text for `--target-list` option from output of
# `./configure --help`
TARGETS="i386-softmmu x86_64-softmmu mipsel-softmmu mips-softmmu arm-softmmu"
CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--target-list='$TARGETS'		\\
"

install_post() {
	cat <<EOF

To use qemu-bridge-helper, appropriate permission bits need to be set

	sudo chown root:root $INSTALL_PREFIX/libexec/qemu-bridge-helper
	sudo chmod u+s $INSTALL_PREFIX/libexec/qemu-bridge-helper

EOF
}
