#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# e2fsprogs provides libuuid library which is usually provided by util-linux.
# But util-linux is linux-specific so that libuuid should better be provided by
# e2fsprogs
#
PKG_NAME=e2fsprogs
PKG_VERSION=1.45.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9bbf7ce425dfe58d3d54f1bb679aaf07

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--with-crond-dir="$INSTALL_PREFIX/etc/cron.d"
	--with-systemd-unit-dir="$INSTALL_PREFIX/lib/systemd/system"
	--with-udev-rules-dir="$INSTALL_PREFIX/lib/udev/rules.d"
)

configure_static_build() {
	configure_static_build_default
	CONFIGURE_ARGS+=( --disable-elf-shlibs)
}

configure_static_build_off() {
	CONFIGURE_ARGS+=( --enable-elf-shlibs)
}

MAKE_VARS+=(
	V=s
)
