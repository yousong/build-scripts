#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=openssh
PKG_VERSION=8.0p1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bf050f002fe510e1daecd39044e1122d
PKG_DEPENDS='openssl'

. "$PWD/env.sh"

#
# GSSAPIAuthentication requires GSSAPI support from --with-kerberos5
#
# privilege separation directory
CONFIGURE_ARGS+=(
	--with-privsep-path="$INSTALL_PREFIX/var/empty"
)
