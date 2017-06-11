#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Percona 5.7.14-7 requires specifically boost 1.59.0, that's the reason why we
# have it here
#
PKG_NAME=boost1.59
PKG_VERSION=1.59.0
PKG_SOURCE="boost_$(echo $PKG_VERSION | tr . _).tar.bz2"
PKG_SOURCE_URL="https://downloads.sourceforge.net/boost/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6aa9a5c6a4ca1016edd0ed1178e3cb87

. "$PWD/env.sh"
. "$PWD/utils-boost.sh"
