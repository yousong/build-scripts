#!/bin/sh -e
#
PKG_NAME=augeas
PKG_VERSION=1.4.0
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://download.augeas.net/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a2536a9c3d744dc09d234228fe4b0c93

. "$PWD/env.sh"
main
