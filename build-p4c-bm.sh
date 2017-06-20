#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Install requirements.txt
#
#	cd "$PKG_SOURCE_DIR"
#	pip install -r requirements.txt
#	pip install -r requirements_v1.1.txt
#
PKG_NAME=p4c-bm
PKG_VERSION=2017-06-20
PKG_SOURCE_VERSION=754e26523ce3bec86b1d830fc803fb92451e9eaf
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/p4lang/p4c-bm/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PYTHON_VERSIONS=2

. "$PWD/env.sh"
. "$PWD/utils-python.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
EOF
}
