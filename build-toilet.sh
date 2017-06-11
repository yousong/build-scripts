#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Examples
#
#	toilet --filter list
#	toilet --gay Hello World
#	toilet --metal Hello World
#	toilet --filter border:metal World
#	toilet --font smmono12 Hello
#
# Links
#
# - homepage, http://caca.zoy.org/wiki/toilet
#
PKG_NAME=toilet
PKG_VERSION=0.3
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://caca.zoy.org/raw-attachment/wiki/toilet/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9b72591cb22a30c42a3184b17cabca6f
PKG_DEPENDS='libcaca'

. "$PWD/env.sh"
