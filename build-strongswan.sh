#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# See INSTALL file for details about required/optional packages/features
#
PKG_NAME=strongswan
PKG_VERSION=5.5.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://download.strongswan.org/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4eba9474f7dc6c8c8d7037261358e68d
PKG_DEPENDS='gmp'

. "$PWD/env.sh"
