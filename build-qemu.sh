#!/bin/sh -e

PKG_NAME=qemu
PKG_VERSION="2.3.0"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://wiki.qemu-project.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="2fab3ea4460de9b57192e5b8b311f221"

. "$PWD/env.sh"

# Others targets can be found in text for `--target-list` option from output of
# `./configure --help`
TARGETS="i386-softmmu x86_64-softmmu mipsel-softmmu mips-softmmu arm-softmmu"
CONFIGURE_ARGS="--target-list='$TARGETS'"

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
#
#	repo=qemu/
#	tag=v2.3.0
#   cd "$DIR_REPO"
#   mkdir -p "$BUILD_DIR"
#   git archive --format=tar "$tag" | tar -C "$BUILD_DIR" -x

install_post() {
	cat <<EOF

To use qemu-bridge-helper, appropriate permission bits need to be set

	sudo chown root:root $INSTALL_PREFIX/libexec/qemu-bridge-helper
	sudo chmod u+s $INSTALL_PREFIX/libexec/qemu-bridge-helper

EOF
}

