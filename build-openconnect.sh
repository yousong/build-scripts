#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=openconnect
PKG_VERSION=7.08
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="ftp://ftp.infradead.org/pub/openconnect/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ca2ca1f61b8515879b481dcf6ed4366b
PKG_DEPENDS='gnutls libxml2 lz4 zlib'

. "$PWD/env.sh"

openconnect_vpnc_script_source_version=07c3518dd6b8dc424e9c3650a62bed994a4dcbe1
openconnect_vpnc_script_source=vpnc-script-$openconnect_vpnc_script_source_version
openconnect_vpnc_script_source_url="http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/$openconnect_vpnc_script_source_version:/vpnc-script"
openconnect_vpnc_script_source_md5sum=9b80eff3abd165e915aa897b2aa6a812

download_extra() {
	download_http \
		"$openconnect_vpnc_script_source" \
		"$openconnect_vpnc_script_source_url" \
		"$openconnect_vpnc_script_source_md5sum"
}

openconnect_vpnc_script="$INSTALL_PREFIX/etc/vpnc/vpnc-script"
CONFIGURE_ARGS+=(
	--with-vpnc-script="$openconnect_vpnc_script"
)

staging_post() {
	local dstf="$PKG_STAGING_DIR$openconnect_vpnc_script"

	staging_post_default

	mkdir -p "$(dirname "$dstf")"
	cp "$BASE_DL_DIR/$openconnect_vpnc_script_source" "$dstf"
	chmod a+x "$dstf"
}
