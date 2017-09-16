#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=wireguard
PKG_VERSION=0.0.20170907
PKG_SOURCE="WireGuard-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://git.zx2c4.com/WireGuard/snapshot/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=02c96aeaf8ed099594d379512a088992
PKG_DEPENDS='libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

configure() {
	true
}

compile() {
	cd "$PKG_BUILD_DIR/src"

	# building kernel module requires
	#  - linux-headers-$arch on debian
	$MAKEJ module
	$MAKEJ \
		PREFIX="$INSTALL_PREFIX" \
		tools
}

staging() {
	# The INSTALL_MOD_PATH is for modules_install target
	cd "$PKG_BUILD_DIR/src"
	$MAKEJ \
		PREFIX="$INSTALL_PREFIX" \
		DESTDIR="$PKG_STAGING_DIR"	\
		INSTALL_MOD_PATH="$PKG_STAGING_DIR$INSTALL_PREFIX" \
		install
}

install_post() {
	__errmsg  "
Make keys

	umask 077; wg genkey | tee privatekey | wg pubkey >publickey

Prepare a simple config: wg0.conf

	cat >wg0.conf <<-EOF
		[Interface]
		PrivateKey = \$privatekey_self
		ListenPort = 21841

		[Peer]
		PublicKey = \$publickey_peer
		Endpoint = \$host_peer:\$port_peer
		AllowedIPs = 0.0.0.0/0
	EOF

Prepare a simple start script: wg0.sh

	#!/bin/bash
	sudo modprobe udp_tunnel
	sudo modprobe ip6_udp_tunnel
	sudo insmod \"$INSTALL_PREFIX/lib/modules/$(uname -r)/extra/wireguard.ko\"

	ip link add wg0 type wireguard
	ip addr add 192.168.175.2/24 dev wg0
	wg setconf wg0 \"$INSTALL_PREFIX/.usr/etc/wireguard/wg0.conf\"
	ip link set wg0 up
"
}
