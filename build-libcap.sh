#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libcap
PKG_VERSION=2.25
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6666b839e5d46c2ad33fc8aa2ceb5f77

. "$PWD/env.sh"

configure() {
	true
}

# When installing setcap, set its inheritable bit to be able to place
# capabilities on files. It can be used in conjunction with pam_cap
# (associated with su and certain users say) to make it useful for
# specially blessed users. If you wish to drop this install feature,
# use this command when running install
#
#    make RAISE_SETFCAP=no install
#
MAKE_VARS="$MAKE_VARS			\\
	prefix='$INSTALL_PREFIX'	\\
	RAISE_SETFCAP=no			\\
"
