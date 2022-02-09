#!/bin/bash -e
#
# Copyright 2016-2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=json-c
PKG_VERSION=0.15
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://s3.amazonaws.com/json-c_releases/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=55f395745ee1cb3a4a39b41636087501
PKG_CMAKE=1

. "$PWD/env.sh"
