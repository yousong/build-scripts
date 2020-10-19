#!/bin/bash -e
#
# Copyright 2019-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# > headers defining protocols
#
PKG_NAME=spice-protocol
PKG_VERSION=0.14.3
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.spice-space.org/download/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=950e08044497ca9cf64e368cb3ceb395
PKG_MESON=1

. "$PWD/env.sh"
