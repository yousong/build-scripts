#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Uhh, CentOS does not provide .rpm for this
#
# Requires
#
# 	sudo yum install -y fcgi-devel
#
PKG_NAME=fcgiwrap
PKG_VERSION=1.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/gnosek/fcgiwrap/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=d14f56bda6758a6e02aa7b3fb125cbce
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"
