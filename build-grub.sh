#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=grub
PKG_VERSION=2.04
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://ftp.gnu.org/gnu/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5aaca6713b47ca2456d8324a58755ac7

. "$PWD/env.sh"

grub_amd64_efi() {
	CONFIGURE_ARGS+=(
		--with-platform=efi
		--target=x86_64
	)
}

grub_i386_pc() {
	CONFIGURE_ARGS+=(
		--with-platform=pc
		--target=i386
	)
}

#grub_amd64_efi
