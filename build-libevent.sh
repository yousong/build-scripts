#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This is mainly for tmux-2.x on CentOS 6.6
#
PKG_NAME=libevent
PKG_VERSION=2.0.22
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-stable.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/levent/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=c4c56f986aa985677ca1db89630a2e11
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=openssl

. "$PWD/env.sh"
