#!/bin/sh -e
#
# configure requires gawk
#
PKG_NAME=quagga
PKG_VERSION=0.99.24
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/quagga/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f1dce9efba8d1ca359f2998f4575206d

. "$PWD/env.sh"

configure_pre() {
	cd "$PKG_SOURCE_DIR"
	# this is required otherwise configure script may complain that it
	# counldn't find install-sh or such things
	autoconf_fixup
}
