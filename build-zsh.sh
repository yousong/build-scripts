#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=zsh
PKG_VERSION=5.7.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/zsh/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=374f9fdd121b5b90e07abfcad7df0627
PKG_DEPENDS='libiconv ncurses'

. "$PWD/env.sh"
