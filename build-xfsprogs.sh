#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# e2fsprogs provides libuuid library which is usually provided by util-linux.
# But util-linux is linux-specific so that libuuid should better be provided by
# e2fsprogs
#
PKG_NAME=xfsprogs
PKG_VERSION=5.4.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://mirrors.edge.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/xfsprogs-5.4.0.tar.xz"
PKG_SOURCE_MD5SUM=61232b1cc453780517d9b0c12ff1699b

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--without-systemd-unit-dir
)
