#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - For language-specific installation instructions for gRPC runtime,
#   https://github.com/grpc/grpc/blob/master/INSTALL.md
#
PKG_NAME=grpc
PKG_VERSION=1.4.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/grpc/grpc/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='c-ares openssl protobuf zlib'

. "$PWD/env.sh"
env_init_gnu_toolchain

# gRPC's Makefile was automatically generated from templates/Makefile.template.  The generated Makefile will have the following quirks and assumptions
#
# - $(AR) contains command arguments like cru
# - LD and LDXX should refer to driver gcc/g++, instead of ld command.
# - It will convert -Lxx argument from output of "pkg-config --libs" to
#   -Wl,-rpath,xx
# - the grpc core version was 4.0.0 and lang ext had 1.4.5, but all symbolic
#   link to shared libraries take the major version of core as the suffix,
#   which is wrong.
do_patch() {
	cd "$PKG_SOURCE_DIR"
	sed -i \
		-e 's:.*s/L/Wl,-rpath:#\0:' \
		-e 's:.* ldconfig :#\0:' \
		-e 's:_PC_TEMPLATE = prefix=$(prefix),:_PC_TEMPLATE = prefix=$(install_prefix),:' \
		Makefile
	# grep -n '\.4$' Makefile | grep -v CORE
	sed -i -e 's:\(ln -sf .*$(SHARED_EXT_\(CPP\|CSHARP\)) .*\)\.so\.4$:\1.so.1:' Makefile
}

configure() {
	true
}

# -Wno-error=shadow
#
#	src/core/ext/filters/client_channel/client_channel.c: In function ‘lookup_external_connectivity_watcher’:
#	src/core/ext/filters/client_channel/client_channel.c:1459:40: error: declaration of ‘on_complete’ shadows a global declaration [-Werror=shadow]
#	src/core/ext/filters/client_channel/client_channel.c:1243:13: error: shadowed declaration is here [-Werror=shadow]
#
# -Wno-error=implicit-fallthrough
#
#	src/core/lib/support/murmur_hash.c: In function 'gpr_murmur_hash3':
#	src/core/lib/support/murmur_hash.c:79:10: error: this statement may fall through [-Werror=implicit-fallthrough=]
#	       k1 ^= ((uint32_t)tail[2]) << 16;
#	       ~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	src/core/lib/support/murmur_hash.c:80:5: note: here
#	     case 2:
#	     ^~~~
#
# -Wno-error=conversion
#
#	src/core/ext/transport/cronet/transport/cronet_transport.c: In function 'create_grpc_frame':
#	src/core/ext/transport/cronet/transport/cronet_transport.c:667:10: error: conversion to 'uint8_t {aka unsigned char}' from 'int' may alter its value [-Werror=conversion]
#	   *p++ = (flags & GRPC_WRITE_INTERNAL_COMPRESS) ? 1 : 0;
#	          ^
EXTRA_CFLAGS+=(
	-Wno-error=shadow
	-Wno-error=implicit-fallthrough
	-Wno-error=conversion
)

MAKE_VARS+=(
	prefix="$PKG_STAGING_DIR$INSTALL_PREFIX"
	install_prefix="$INSTALL_PREFIX"
	AR="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ar cru"
	LD="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-gcc"
	LDXX="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-g++"
#	V=1
)
