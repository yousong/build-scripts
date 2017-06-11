#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
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
