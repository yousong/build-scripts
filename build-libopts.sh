#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# GnuTLS includes a local copy of libopts.  To use external libs, it also needs
# autogen program which depends on guile.  For GnuTLS, better just stick to the
# local copy
#
PKG_NAME=libopts
PKG_VERSION=27.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://ftp.gnu.org/old-gnu/libopts/rel$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b66e4c01576f9bc6c9cd103e5e829e69

. "$PWD/env.sh"
