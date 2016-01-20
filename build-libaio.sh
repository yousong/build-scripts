#!/bin/sh -e
#
PKG_NAME=libaio
PKG_VERSION="0.3.110-1"
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://git.fedorahosted.org/cgit/libaio.git/snapshot/$PKG_SOURCE"
PKG_PLATFORM=linux

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS="prefix='$PKG_STAGING_DIR$INSTALL_PREFIX'"
