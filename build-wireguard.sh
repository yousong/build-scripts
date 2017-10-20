#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=wireguard
PKG_VERSION=0.0.20171017
PKG_SOURCE="WireGuard-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://git.zx2c4.com/WireGuard/snapshot/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1184c5734f7cd3b5895157835a336b3d
PKG_DEPENDS='libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	# Patch was made with
	#
	#	for f in `grep -r -l /etc/wireguard`; do cp $f $f.orig; done
	#	for f in `grep -r -l --exclude "*.orig" /etc/wireguard`; do sed -i -e 's:/etc/wireguard/:$INSTALL_PREFIX\0:g' $f; done
	#	for f in `grep -r -l --exclude "*.orig" /etc/wireguard`; do diff -uprN $f.orig $f; done
	#
	# Sane people do not have colon in there pathes...
	#
	cd "$PKG_SOURCE_DIR"
	sed -e "s:\$INSTALL_PREFIX:$INSTALL_PREFIX:g" <<"EOF" | patch -p0
--- src/tools/wg-quick.bash.orig	2017-09-19 16:43:16.066306694 +0800
+++ src/tools/wg-quick.bash	2017-09-19 16:44:59.066430339 +0800
@@ -27,7 +27,7 @@ ARGS=( "$@" )
 parse_options() {
 	local interface_section=0 line key value
 	CONFIG_FILE="$1"
-	[[ $CONFIG_FILE =~ ^[a-zA-Z0-9_=+.-]{1,16}$ ]] && CONFIG_FILE="/etc/wireguard/$CONFIG_FILE.conf"
+	[[ $CONFIG_FILE =~ ^[a-zA-Z0-9_=+.-]{1,16}$ ]] && CONFIG_FILE="$INSTALL_PREFIX/etc/wireguard/$CONFIG_FILE.conf"
 	[[ -e $CONFIG_FILE ]] || die "\`$CONFIG_FILE' does not exist"
 	[[ $CONFIG_FILE =~ /?([a-zA-Z0-9_=+.-]{1,16})\.conf$ ]] || die "The config file must be a valid interface name, followed by .conf"
 	((($(stat -c '%#a' "$CONFIG_FILE") & 0007) == 0)) || echo "Warning: \`$CONFIG_FILE' is world accessible" >&2
@@ -210,7 +210,7 @@ cmd_usage() {
 
 	  CONFIG_FILE is a configuration file, whose filename is the interface name
 	  followed by \`.conf'. Otherwise, INTERFACE is an interface name, with
-	  configuration found at /etc/wireguard/INTERFACE.conf. It is to be readable
+	  configuration found at $INSTALL_PREFIX/etc/wireguard/INTERFACE.conf. It is to be readable
 	  by wg(8)'s \`setconf' sub-command, with the exception of the following additions
 	  to the [Interface] section, which are handled by $PROGRAM:
 
--- src/tools/wg-quick.8.orig	2017-09-19 16:43:16.070306699 +0800
+++ src/tools/wg-quick.8	2017-09-19 16:44:59.070430344 +0800
@@ -28,7 +28,7 @@ runs pre/post down scripts.
 
 \fICONFIG_FILE\fP is a configuration file, whose filename is the interface name
 followed by `.conf'. Otherwise, \fIINTERFACE\fP is an interface name, with configuration
-found at `/etc/wireguard/\fIINTERFACE\fP.conf'.
+found at `$INSTALL_PREFIX/etc/wireguard/\fIINTERFACE\fP.conf'.
 
 Generally speaking, this utility is just a simple script that wraps invocations to
 .BR wg (8)
@@ -177,11 +177,11 @@ in the filename:
 \fB    # wg-quick up /path/to/wgnet0.conf\fP
 
 For convienence, if only an interface name is supplied, it automatically chooses a path in
-`/etc/wireguard/':
+`$INSTALL_PREFIX/etc/wireguard/':
 
 \fB    # wg-quick up wgnet0\fP
 
-This will load the configuration file `/etc/wireguard/wgnet0.conf'.
+This will load the configuration file `$INSTALL_PREFIX/etc/wireguard/wgnet0.conf'.
 
 .SH SEE ALSO
 .BR wg (8),
--- src/tools/completion/wg-quick.bash-completion.orig	2017-09-19 16:43:16.070306699 +0800
+++ src/tools/completion/wg-quick.bash-completion	2017-09-19 16:44:59.074430348 +0800
@@ -8,7 +8,7 @@ _wg_quick_completion() {
 		if [[ ${COMP_WORDS[1]} == up ]]; then
 			local old_glob="$(shopt -p nullglob)"
 			shopt -s nullglob
-			for i in /etc/wireguard/*.conf; do
+			for i in $INSTALL_PREFIX/etc/wireguard/*.conf; do
 				i="${i##*/}"; i="${i%.conf}"
 				mapfile -t a < <(compgen -W "$i" -- "${COMP_WORDS[2]}")
 				COMPREPLY+=( "${a[@]}" )
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
	$MAKEJ "${MAKE_VARS[@]}" \
		module \
		tools \

}

staging() {
	cd "$PKG_BUILD_DIR/src"
	$MAKEJ "${MAKE_VARS[@]}" install
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
