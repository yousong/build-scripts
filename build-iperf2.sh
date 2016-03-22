#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=iperf2
PKG_VERSION=2.0.8
PKG_SOURCE=iperf-$PKG_VERSION-source.tar.gz
PKG_SOURCE_URL="https://iperf.fr/download/iperf_$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=e5887f799d8dc64a974c6c2f2e5cc339
PKG_PLATFORM=linux

PKG_BUILD_DIR_BASENAME=iperf-$PKG_VERSION
. "$PWD/env.sh"
