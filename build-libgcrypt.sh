#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libgcrypt
PKG_VERSION=1.8.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://www.gnupg.org/ftp/gcrypt/libgcrypt/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=348cc4601ca34307fc6cd6c945467743
PKG_DEPENDS='libgpg-error'

. "$PWD/env.sh"
