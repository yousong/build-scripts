#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

. "$PWD/utils-openvswitch.sh"

PKG_VERSION="$PKG_ovn_VERSION"
PKG_SOURCE="$PKG_ovn_SOURCE"
PKG_SOURCE_URL="$PKG_ovn_SOURCE_URL"
PKG_SOURCE_MD5SUM="$PKG_ovn_SOURCE_MD5SUM"

PKG_NAME=ovn
PKG_DEPENDS="openssl openvswitch"
PKG_PLATFORM=linux

. "$PWD/env.sh"
STRIP=()

# --enable-ndebug, disable debugging features for max performance
# --with-debug, only takes effect for msvc by passing -O0
#
CONFIGURE_ARGS+=(
	--enable-shared
	--enable-ndebug
	--with-ovs-source="$PKG_BUILD_DIR/../$PKG_openvswitch_NAME-$PKG_openvswitch_VERSION"
	--with-ovs-build="$PKG_BUILD_DIR/../$PKG_openvswitch_NAME-$PKG_openvswitch_VERSION"
)

configure_pre() {
	cd "$PKG_BUILD_DIR"

	if [ ! -x "$PKG_BUILD_DIR/configure" ]; then
		"$PKG_BUILD_DIR/boot.sh"
	fi

	configure_pre_default
}

staging() {
	local d0="$PKG_STAGING_DIR$INSTALL_PREFIX"

	build_staging 'install'
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovn-ctl"
}
