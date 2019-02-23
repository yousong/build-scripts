#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=osinfo-db-tools
PKG_VERSION=1.2.0
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://releases.pagure.org/libosinfo/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=2f93409f83c948e38f15cb4852bfe0e7
PKG_DEPENDS='bzip2 libffi libiconv libxml2 libxslt lz4 nettle openssl pcre util-linux xz zlib'

. "$PWD/env.sh"

osinfo_db_VERSION=20190218
osinfo_db_SOURCE="osinfo-db-$osinfo_db_VERSION.tar.xz"
osinfo_db_SOURCE_URL="https//releases.pagure.org/libosinfo/$osinfo_db_VERSION"
osinfo_db_MD5SUM=52f0f7382911ee7fcd1984fd32c52027

download_extra() {
	download_http "$osinfo_db_SOURCE" "$osinfo_db_SOURCE_URL" "$osinfo_db_MD5SUM"
}

osinfo_db_deploy() {
	# osinfo-db-path --system
	# osinfo-db-path --local
	# osinfo-db-path --user
	# osinfo-db-path --root aroot/ --dir customdir
	osinfo-db-import --verbose --system "$BASE_DL_DIR/$osinfo_db_SOURCE"
}
