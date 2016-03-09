#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# libxml-2.0 is required
#
#	sudo yum install libxml2-devel
#
# augtool requires readline
#
PKG_NAME=augeas
PKG_VERSION=1.4.0
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://download.augeas.net/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a2536a9c3d744dc09d234228fe4b0c93
PKG_DEPENDS=readline

. "$PWD/env.sh"
