#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=flex
PKG_VERSION=2.6.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/westes/flex/releases/download/v$PKG_VERSION/$PKG_SOURCE"

. "$PWD/env.sh"
