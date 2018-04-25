#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Requires
#
#	libdrm-devel mesa-libgbm-devel libepoxy-devel
#
PKG_NAME=virglrenderer
PKG_VERSION=0.6.0
PKG_SOURCE_URL="git://git.freedesktop.org/git/virglrenderer"
PKG_SOURCE_VERSION=76b3da97b5fd98b1669147db585bed7ccfaf11a7
PKG_DEPENDS=swiftshader

. "$PWD/env.sh"

configure_pre() {
	cd "$PKG_BUILD_DIR"
	./autogen.sh
}
