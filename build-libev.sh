#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libev
PKG_VERSION=4.24
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://dist.schmorp.de/libev/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=94459a5a22db041dec6f98424d6efe54

. "$PWD/env.sh"

staging_post() {
	# the compat header can override libevent2's
	rm -vf "$PKG_STAGING_DIR$INSTALL_PREFIX/include/event.h"
	staging_post_default
}
