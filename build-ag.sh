#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# silversearcher-ag is available in Debian since release jessie.
#
#   apt-get install silversearcher-ag
#
# To manually build it, the following package needs to be installed.
#
#   apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev
#
#   yum -y groupinstall "Development Tools"
#   yum -y install pcre-devel xz-devel
#
# See https://github.com/ggreer/the_silver_searcher for details.
#
PKG_NAME=ag
PKG_VERSION=2.2.0
PKG_SOURCE="the_silver_searcher-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://geoff.greer.fm/ag/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=958a614cbebf47b2f27a7d00a5bb1bcb
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='pcre xz zlib'

. "$PWD/env.sh"
