#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=nettle
PKG_VERSION=3.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://ftp.gnu.org/gnu/nettle/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=afb15b4764ebf1b4e6d06c62bd4d29e4
PKG_DEPENDS=gmp

. "$PWD/env.sh"
