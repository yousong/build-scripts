#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# iostat
#
#  - svctm was removed
#  - %util can be misleading for devices capable of parallel ops
#
# - Matrix of activities, http://sebastien.godard.pagesperso-orange.fr/matrix.html
# - Documentation, http://sebastien.godard.pagesperso-orange.fr/documentation.html
#
PKG_NAME=sysstat
PKG_VERSION=12.3.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://pagesperso-orange.fr/sebastien.godard/$PKG_SOURCE"

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	# don't do ownership change
	--disable-file-attr
)

CONFIGURE_VARS+=(
	conf_dir="$INSTALL_PREFIX/etc/sysconfig"
	sa_dir="$INSTALL_PREFIX/var/log/sa"
)

if [ -n "$o_build_static" ]; then
	EXTRA_LDFLAGS+=( -static )
fi
MAKE_VARS+=(
	LFLAGS="${EXTRA_LDFLAGS[*]}"
)
