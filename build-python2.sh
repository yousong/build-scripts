#!/bin/bash -e
#
# Copyright 2015-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Do metadata_gen_listing, uninstall before installing minor version number
# bumped release
#
PKG_NAME=python2
PKG_VERSION=2.7.18
PKG_SOURCE="Python-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.python.org/ftp/python/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=fd6cc8ec0a78c44036f825e739f36e5a
PKG_DEPENDS='bzip2 db openssl ncurses readline sqlite zlib'

. "$PWD/env.sh"
. "$PWD/utils-python.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	do_patch_python23
	do_patch_python2
}

CONFIGURE_ARGS+=(
	--enable-shared
	--enable-unicode=ucs4
	--with-ensurepip=upgrade
)

install_post() {
	local d p

	__errmsg "To use packages installed in system site-packages"
	__errmsg
	__errmsg "	rm -vf $INSTALL_PREFIX/lib/python2.7/site-packages/system.pth"
	for p in /usr/lib /usr/lib64; do
		d="$p/python2.7/site-packages"
		if [ -d "$d" ]; then
			__errmsg "	echo $d >>$INSTALL_PREFIX/lib/python2.7/site-packages/system.pth"
		fi
	done
}
