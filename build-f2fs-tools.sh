#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=f2fs-tools
PKG_VERSION=1.13.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0c92a4990168ff57c72075e738998635
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"
