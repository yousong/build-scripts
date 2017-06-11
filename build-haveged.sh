#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Run it in foreground with all verbose info
#
#	sudo ./haveged -F -v 63
#
# Check current available entropy
#
#	cat /proc/sys/kernel/random/entropy_avail
#
PKG_NAME=haveged
PKG_VERSION=1.9.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.issihosts.com/haveged/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=015ff58cd10607db0e0de60aeca2f5f8

. "$PWD/env.sh"
