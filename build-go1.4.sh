#!/bin/sh -e
#
PKG_NAME=go1.4
PKG_VERSION=1.4.3
PKG_SOURCE="go$PKG_VERSION.src.tar.gz"
PKG_SOURCE_URL="https://storage.googleapis.com/golang/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=dfb604511115dd402a77a553a5923a04
PKG_BUILD_DIR_BASENAME="go-$PKG_VERSION"

. "$PWD/env.sh"
. "$PWD/utils-go.sh"
