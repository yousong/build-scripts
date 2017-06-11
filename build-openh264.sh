#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# OpenH264 cannot build with ffmpeg 3.1 at the moment.  Patch is only available
# for ffmpeg master [1]
#
#  [1] https://git.ffmpeg.org/gitweb/ffmpeg.git/commitdiff/293676c476733e81d7b596736add6cd510eb6960
#
PKG_NAME=openh264
PKG_VERSION=1.6.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/cisco/$PKG_NAME/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=44fa88fa8545ab1239a16ad535078be4

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
