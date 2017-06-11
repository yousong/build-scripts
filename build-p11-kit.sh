#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=p11-kit
PKG_VERSION=0.23.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://p11-glue.freedesktop.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=738af2442331fc22f440df9bee9b062a
PKG_DEPENDS='libtasn1 libffi'

. "$PWD/env.sh"
