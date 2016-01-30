#!/bin/sh -e
#
PKG_NAME=lua5.1
PKG_VERSION=5.1.5
PKG_SOURCE="lua-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.lua.org/ftp/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=2e115fe26e435e33b0d5c022e4490567
PKG_BUILD_DIR_BASENAME="lua-$PKG_VERSION"

. "$PWD/env.sh"
. "$PWD/utils-lua.sh"
