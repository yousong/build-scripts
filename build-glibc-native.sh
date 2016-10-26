#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg glibc
PKG_NAME=glibc-native

# glibc starting with 2.24 requires at least assembler version of at least 2.24
# (sysdeps/x86_64/configure) which is not available in debian wheezy (2.22)
case "$PKG_VERSION" in
	2.2[4-9]*|2.[3-9][0-9]*|[3-9].*)
		PKG_DEPENDS="binutils-native-pass1"
		;;
esac

. "$PWD/env.sh"

toolchain_init_vars_build_native "$PKG_NAME"
