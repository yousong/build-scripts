#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# See man rsyncd.conf and rsync for details of options and arguments
#
# "reverse lookup" is only available since version 3.1.0
#
PKG_NAME=rsync
PKG_VERSION=3.1.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://download.samba.org/pub/rsync/src/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0f758d7e000c0f7f7d3792610fad70cb
PKG_DEPENDS="popt libiconv"

. "$PWD/env.sh"
