#!/bin/bash -e
#
# Copyright 2015-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# openvpn on Debian requires
#
#   apt-get install liblzo2-dev libpam-dev
#
# openvpn on RHEL/CentOS requires
#
#	yum install pam-devel
#
# PKCS11 requires libpkcs11-helper-1 >= 1.11, which is not available in Debian Wheezy (only 1.09 is available)
#
PKG_NAME=openvpn
PKG_VERSION=2.4.6
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://swupdate.openvpn.org/community/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3a1f3f63bdaede443b4df49957df9405
PKG_DEPENDS='openssl lzo'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-plugin-auth-pam
)
