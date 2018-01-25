#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# bsdtar 3.1.2 from centos7 can fail with the following error when reading
# archlinuxarm .tar.gz files
#
#	bsdtar: Ignoring malformed pax extended attribute
#	bsdtar: Ignoring malformed pax extended attribute
#	bsdtar: Ignoring malformed pax extended attribute
#	bsdtar: Ignoring malformed pax extended attribute
#	bsdtar: Error exit delayed from previous errors.
#
PKG_NAME=libarchive
PKG_VERSION=3.3.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.libarchive.org/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4583bd6b2ebf7e0e8963d90879eb1b27

. "$PWD/env.sh"
