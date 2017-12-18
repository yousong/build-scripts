#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Docker Compose overview, https://docs.docker.com/compose/overview/
#
PKG_NAME=docker-compose
PKG_VERSION=1.17.1
PKG_SOURCE="docker-compose-Linux-x86_64"
PKG_SOURCE_URL="https://github.com/docker/compose/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=108e1b70a41e2a453e70932e56935ef6
PKG_DEPENDS='docker linux'

. "$PWD/env.sh"

prepare() {
	true
}

configure() {
	true
}

compile() {
	true
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"
	mkdir -p "$bindir"
	cp "$BASE_DL_DIR/$PKG_SOURCE" "$bindir/$PKG_NAME"
	chmod +x "$bindir/$PKG_NAME"
}
