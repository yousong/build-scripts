#!/bin/bash -e
#
# Copyright 2017-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# On RHEL/CentOS, wireguard expects distributions' recent kernel versions to
# compile, https://lists.zx2c4.com/pipermail/wireguard/2018-July/003171.html
#
PKG_NAME=wireguard
PKG_VERSION=0.0.20180718
PKG_SOURCE="WireGuard-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://git.zx2c4.com/WireGuard/snapshot/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=84ebc06f9efc5ea121df54bf6799d983
PKG_DEPENDS='libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

wg_prep_patch() {
	local f

	prepare_source
	cd "$PKG_SOURCE_DIR"
	for f in `grep -r -l /etc/wireguard`; do cp $f $f.orig; done
	for f in `grep -r -l --exclude "*.orig" /etc/wireguard`; do sed -i -e 's:/etc/wireguard/:$INSTALL_PREFIX\0:g' $f; done
	for f in `grep -r -l --exclude "*.orig" /etc/wireguard`; do diff -uprN $f.orig $f; done
}

do_patch() {
	cd "$PKG_SOURCE_DIR"
	sed -e "s:\$INSTALL_PREFIX:$INSTALL_PREFIX:g" <<"EOF" | patch -p0
EOF
}

configure() {
	true
}

# INSTALL_MOD_PATH is for modules_install target
#
# wg-quick is a bash script that requires resolvconf and ip-rule with
# suppress_prefixlength support
#
# SYSCONFDIR defaults to /etc and has to be overridden here
MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	DESTDIR="$PKG_STAGING_DIR"
	INSTALL_MOD_PATH="$PKG_STAGING_DIR$INSTALL_PREFIX"
	SYSCONFDIR="$INSTALL_PREFIX/etc"
	WITH_WGQUICK=yes
	WITH_SYSTEMDUNITS=no
)

compile() {
	cd "$PKG_BUILD_DIR/src"

	# building kernel module requires
	#  - linux-headers-$arch on debian
	"${MAKEJ[@]}" "${MAKE_VARS[@]}" \
		module \
		tools \

}

staging() {
	cd "$PKG_BUILD_DIR/src"
	"${MAKEJ[@]}" "${MAKE_VARS[@]}" install
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

	# Make sure /etc/depmod.d/ has settings to lookup modules directories
	# under $INSTALL_PREFIX
	#
	modprobe wireguard

	ip link add wg0 type wireguard
	ip addr add 192.168.175.2/24 dev wg0
	wg setconf wg0 \"$INSTALL_PREFIX/etc/wireguard/wg0.conf\"
	ip link set wg0 up
"
}
