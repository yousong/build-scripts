#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=smartmontools
PKG_VERSION=7.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/smartmontools/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=430cd5f64caa4524018b536e5ecd9c29

. "$PWD/env.sh"
