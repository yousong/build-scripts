#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# socat on Debian Wheezy 7 has version 1.7.1.3 and lacking readline support
#
PKG_NAME=socat
PKG_VERSION=2.0.0-b8
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://www.dest-unreach.org/socat/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ff56576703dfdeac221357a348c30760
PKG_DEPENDS='readline openssl'

. "$PWD/env.sh"
