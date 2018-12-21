#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Can be useful when for a build farm.  HAProxy also has distcc protocol
# support with distcc_param, distcc_body sampling method.
#
# distcc wire protocols can be found at doc/ subdir.  3 versions are availables
# as of 2018-12-21.
#
#  - protocol 1
#  - protocol 2 compresses bulk content with LZ01X
#  - protocol 3 adds distributed preprocessing support
#
# distcc's protocols are text based with each command operator being comprised
# of 4 uppercase letters, size of length are represented with 8 hexadeciaml digits
#
PKG_NAME=distcc
PKG_VERSION=3.3.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/distcc/distcc/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=648c0f9917905e0636a2c613d6ba7027
PKG_DEPENDS='python3'
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure() {
	cd "$PKG_BUILD_DIR"
	./autogen.sh
	build_configure_default
}
