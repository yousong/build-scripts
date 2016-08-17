#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=fdk-aac
PKG_VERSION=0.1.4
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/mstorsjo/fdk-aac/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=5292a28369a560d37d431de625bedc34
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"
