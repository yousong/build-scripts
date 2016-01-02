#!/bin/sh -e
#
# Requires Apache Portable Runtime @apr
# Requires Apache Portable Runtime utility @apr-util
#
# HTTP/2 support was available starting with Apache 2.4.12, then at 2.4.17
# mod_http2 was introduced
#
# - Official Patches for publically released versions of Apache, http://www.us.apache.org/dist//httpd/patches/
#
PKG_NAME=httpd
PKG_VERSION=2.4.18
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.us.apache.org/dist//httpd/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3690b3cc991b7dfd22aea9e1264a11b9

. "$PWD/env.sh"
INSTALL_PREFIX="$INSTALL_PREFIX/httpd"
