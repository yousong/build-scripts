#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=boost1.61
PKG_VERSION=1.61.0
PKG_SOURCE="boost_$(echo $PKG_VERSION | tr . _).tar.bz2"
PKG_SOURCE_URL="https://downloads.sourceforge.net/boost/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6095876341956f65f9d35939ccea1a9f

. "$PWD/env.sh"
. "$PWD/utils-boost.sh"
