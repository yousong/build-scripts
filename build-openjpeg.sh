#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=openjpeg
PKG_VERSION=2.1.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/uclouvain/openjpeg/archive/v${PKG_VERSION}.tar.gz"
PKG_SOURCE_MD5SUM=0cc4b2aee0a9b6e9e21b7abcd201a3ec
PKG_CMAKE=1

. "$PWD/env.sh"
