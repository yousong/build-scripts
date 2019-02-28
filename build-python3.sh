#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# With GCC version prior to 4.5 (like the case with CentOS 6, the build log
# will be flooded with the following warning messages which should be okay to
# live with
#
#		warning: will never be executed
#
# - -Wunreachable-code is broken and has been removed from GCC 4.5. Do not use
#	it. https://gcc.gnu.org/bugzilla/show_bug.cgi?id=46158
#
PKG_NAME=python3
PKG_VERSION=3.7.2
PKG_SOURCE="Python-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.python.org/ftp/python/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=df6ec36011808205beda239c72f947cb
PKG_DEPENDS='bzip2 db openssl ncurses readline sqlite zlib'

. "$PWD/env.sh"
. "$PWD/utils-python.sh"

do_patch() {
	do_patch_python23
}

CONFIGURE_ARGS+=(
	--enable-shared
)
