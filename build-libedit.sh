#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libedit
PKG_VERSION=20181209-3.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.thrysoee.dk/editline/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=22e945a0476e388e6f78bfc8d6e1192c
PKG_DEPENDS=ncurses

. "$PWD/env.sh"
