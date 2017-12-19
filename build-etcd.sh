#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=etcd
PKG_VERSION=3.2.11
PKG_SOURCE="$PKG_NAME-v$PKG_VERSION-linux-amd64.tar.gz"
PKG_SOURCE_URL="https://github.com/coreos/etcd/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b438784933f5df0887f55f0252bc4f3c
PKG_DEPENDS=linux

. "$PWD/env.sh"
STRIP=()

configure() {
	true
}

compile() {
	true
}

ETCD_ROOT="$INSTALL_PREFIX/etcd"
ETCD_ROOT_VER="$ETCD_ROOT/$PKG_NAME-$PKG_VERSION"
ETCD_STAGING="$PKG_STAGING_DIR$ETCD_ROOT_VER"

staging() {
	mkdir -p "$ETCD_STAGING"
	cpdir "$PKG_SOURCE_DIR" "$ETCD_STAGING"
}

install() {
	mkdir -p "$ETCD_ROOT_VER"
	cpdir "$ETCD_STAGING" "$ETCD_ROOT_VER"
}

install_post() {
	cat >&2 <<EOF
To run

	$ETCD_ROOT_VER/etcd

To test

	export ETCDCTL_API=3
	$ETCD_ROOT_VER/etcdctl put foo bar
	$ETCD_ROOT_VER/etcdctl get foo
EOF
}
