#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# netdata requires libuuid which can be provided by e2fsprogs
#
# - https://github.com/firehol/netdata/wiki/Installation
# - https://github.com/firehol/netdata/wiki/Configuration
#
# netdata serves http client on port 19999 by default
#
PKG_NAME=netdata
PKG_VERSION=1.3.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://github.com/firehol/netdata/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b9dd9225ec81a8ee755fbfcd4d54f8f8
PKG_DEPENDS='e2fsprogs zlib'

. "$PWD/env.sh"

staging_post() {
	# touch an empty netdata.conf
	touch "$PKG_STAGING_DIR$INSTALL_PREFIX/etc/netdata/netdata.conf"
}
