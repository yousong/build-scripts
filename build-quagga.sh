#!/bin/sh -e
#
PKG_NAME=quagga
PKG_VERSION=0.99.24
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/quagga/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f1dce9efba8d1ca359f2998f4575206d

. "$PWD/env.sh"

configure_pre() {
	cd "$PKG_BUILD_DIR"
	autoconf_fixup
}
