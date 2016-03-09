#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This package does not support darwin system as of 0.9.1 because relevant
# information on how to include syscall.h is missing in urcu/syscall-compat.h
#
PKG_NAME=liburcu
PKG_VERSION=0.9.1
PKG_SOURCE="userspace-rcu-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.lttng.org/files/urcu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=124eaeea06863271c0bdf2a0cc1d8e4b
PKG_BUILD_DIR_BASENAME="userspace-rcu-$PKG_VERSION"
PKG_PLATFORM=linux

. "$PWD/env.sh"
