#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=talloc
PKG_VERSION=2.1.14
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.samba.org/ftp/talloc/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7478da02e309316231a497a9f17a980d
PKG_DEPENDS="python2"

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-python	# do not generate python modules
)
