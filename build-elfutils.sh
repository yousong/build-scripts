#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=elfutils
PKG_VERSION=0.169
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://sourceware.org/elfutils/ftp/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1ce77c5315d6bba7d883c3c4f0c2697e

. "$PWD/env.sh"
