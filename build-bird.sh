#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# configure requires gawk
#
PKG_NAME=bird
PKG_VERSION=2.0.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://bird.network.cz/pub/bird/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=de17645b045fa13912409aea59420132

. "$PWD/env.sh"
