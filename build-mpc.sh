#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=mpc
PKG_VERSION=1.0.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://ftp.gnu.org/gnu/mpc/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d6a1d5f8ddea3abd2cc3e98f58352d26
PKG_DEPENDS='gmp mpfr'

. "$PWD/env.sh"
