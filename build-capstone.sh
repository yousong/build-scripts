#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=capstone
PKG_VERSION=4.0.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/qemu/capstone/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=1b0a9a0d50d9515dcf7684ce0a2270a4
PKG_CMAKE=1

. "$PWD/env.sh"
