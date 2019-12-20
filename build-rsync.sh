#!/bin/bash -e
#
# Copyright 2017-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# See man rsyncd.conf and rsync for details of options and arguments
#
# A sample config: rsync --daemon --config=rsyncd.conf
#
#	max connections = 32
#	use chroot = no
#	lock file = /home/yousong/rsync/rsyncd.lock
#	log file = /home/yousong/rsync/rsync.log
#	port = 7873
#	timeout = 300
#	reverse lookup = no
#
#	[linux]
#	                comment = linux
#	                path = /home/yousong/git-repo/linux
#	                read only = yes
#	                list = yes
#
# "reverse lookup" is only available since version 3.1.0
#
PKG_NAME=rsync
PKG_VERSION=3.1.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://download.samba.org/pub/rsync/src/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1581a588fde9d89f6bc6201e8129afaf
PKG_DEPENDS="popt libiconv"

. "$PWD/env.sh"
