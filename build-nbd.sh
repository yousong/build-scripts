#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=nbd
PKG_VERSION=3.13
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/nbd/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a48ad35ffdcd156477d29388d92e7489
PKG_PLATFORM=linux

. "$PWD/env.sh"
