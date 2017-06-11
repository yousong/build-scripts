#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=stunnel
PKG_VERSION=5.30
PKG_SOURCE="stunnel-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://www.stunnel.org/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7bbf27296a83c0b752f6bb6d1b750b19
PKG_DEPENDS='openssl zlib'

. "$PWD/env.sh"
