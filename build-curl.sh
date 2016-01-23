#!/bin/sh -e
#
# @nghttp2 for HTTP2 support
# @rtmpdump for RTMP support
# @openssl for SSL support
#
PKG_NAME=curl
PKG_VERSION=7.46.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://curl.haxx.se/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9979f989a2a9930d10f1b3deeabc2148
PKG_DEPENDS='nghttp2 rtmpdump openssl zlib'

. "$PWD/env.sh"
