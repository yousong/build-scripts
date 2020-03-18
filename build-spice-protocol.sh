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
PKG_VERSION=0.14.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://www.spice-space.org/download/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=97fea9d82a8c88a1ba9b6ad0f73860a9

. "$PWD/env.sh"
