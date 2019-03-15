#!/bin/bash -e
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
PKG_VERSION=1.11.0
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://download.augeas.net/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=abf51f4c0cf3901d167f23687f60434a
PKG_DEPENDS="libxml2 readline"

. "$PWD/env.sh"
