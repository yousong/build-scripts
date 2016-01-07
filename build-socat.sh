#!/bin/sh -e
#
# socat on Debian Wheezy 7 has version 1.7.1.3 and lacking readline support
#
PKG_NAME=socat
PKG_VERSION=1.7.3.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://www.dest-unreach.org/socat/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="b607edb65bc6c57f4a43f06247504274"
PKG_DEPENDS='readline'

. "$PWD/env.sh"
