#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=c-ares
PKG_VERSION=1.13.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://c-ares.haxx.se/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d2e010b43537794d8bedfb562ae6bba2

. "$PWD/env.sh"
