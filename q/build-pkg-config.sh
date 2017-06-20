#!/bin/bash -e

PKG_NAME=pkg-config
PKG_VERSION=0.29
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://pkgconfig.freedesktop.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=77f27dce7ef88d0634d0d6f90e03a77f
PKG_DEPENS=m4

. "$PWD/env.sh"

staging_post() {
	cp /usr/bin/pkg-config "$PKG_STAGING_DIR$INSTALL_PREFIX/bin/pkg-config"
}
