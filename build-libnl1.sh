#!/bin/sh -e
#
PKG_NAME=libnl1
PKG_VERSION=1.1.4
PKG_SOURCE="libnl-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.infradead.org/~tgr/libnl/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=580cb878be536804daca87fb75ae46cc
PKG_PLATFORM=linux

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/libnl-$PKG_VERSION"
PKG_STAGING_DIR="$BASE_DESTDIR/libnl-$PKG_VERSION-install"