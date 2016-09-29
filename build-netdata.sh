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
# - Use /netdata.conf to fetch a complete config
# - Data stores in subdirs of var/cache/netdata
# - Access, error, debug logs are at var/log/netdata
# - Registry is at var/lib/netdata/registry
#
# Things to consider
#
# - History archive to preserve
# - Size limit of Log files
# - Proxy pass with NGINX
#
# - https://github.com/firehol/netdata/wiki/Memory-Requirements
# - https://github.com/firehol/netdata/wiki/Log-Files
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
