#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - mOS Networking Stack, http://mos.kaist.edu/
#
PKG_NAME=mOS
PKG_VERSION=2017-08-21
PKG_SOURCE_VERSION=68e4c9205761dfb8500802216cc0eb5082492175
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/ndsl-kaist/mOS-networking-stack/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=linux

. "$PWD/env.sh"

mOS_FLAVOR=dpdk
mOS_FLAVOR=pcap

prepare_extra() {
	local f

	# bad symlinks in the source code
	cd "$PKG_SOURCE_DIR/core/include"
	for f in $(ls); do
		ln -sf "../src/include/$f" "$f"
	done
}

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
Buggy fix: nic names can contain dash characters

--- a/core/src/config.c.orig	2017-09-13 14:07:27.631552320 +0800
+++ b/core/src/config.c	2017-09-13 14:08:00.219562519 +0800
@@ -110,7 +110,7 @@ DetectWord(char *buf, int len, char **wo
 		return -1;
 
 	for (*wlen = 0; *wlen < len; (*wlen)++) {
-		if (isalnum((*word)[*wlen]) || (*word)[*wlen] == '_')
+		if (isalnum((*word)[*wlen]) || (*word)[*wlen] == '_' || (*word)[*wlen] == '-')
 			continue;
 
 		assert(*wlen != 0);
EOF
}

configure() {
	true
}

CONFIGURE_PATH="$PKG_SOURCE_DIR/scripts"
CONFIGURE_CMD="$PKG_SOURCE_DIR/scripts/configure"

compile() {
	"mOS_compile_mOS_$mOS_FLAVOR"
	mOS_compile_samples
}

mOS_compile_mOS_dpdk() {
	local args

	mOS_compile_dpdk

	args==( "${CONFIGURE_ARGS[@]}" )
	CONFIGURE_ARGS+=(
		--enable-dpdk
	)
	build_configure_default
	CONFIGURE_ARGS=( "${args[@]}" )

	mOS_compile_
}

mOS_compile_dpdk() {
	local dpdk_dir="$PKG_BUILD_DIR/drivers/dpdk"

	# compile dpdk
	export RTE_SDK="$(echo "$PKG_BUILD_DIR/drivers/dpdk-"*)"
	export RTE_TARGET="x86_64-native-linuxapp-gcc"

	cd "$RTE_SDK"
	"${MAKEJ[@]}" install \
		V=1 \
		T="$RTE_TARGET" \
		DESTDIR=. \
		EXTRA_CPPFLAGS="-DNO_PTP_SUPPORT" \

	mkdir -p "$dpdk_dir"
	ln -sf "$RTE_SDK/$RTE_TARGET/include" "$dpdk_dir/include"
	ln -sf "$RTE_SDK/$RTE_TARGET/lib" "$dpdk_dir/lib"
}

mOS_compile_mOS_pcap() {
	args==( "${CONFIGURE_ARGS[@]}" )
	CONFIGURE_ARGS+=(
		--enable-pcap
	)
	build_configure_default
	CONFIGURE_ARGS=( "${args[@]}" )

	mOS_compile_
}

mOS_compile_() {
	local dbg

	cd "$PKG_BUILD_DIR/core/src"
	"${MAKEJ[@]}" clean

	# some debug options may cause -Werror=unused-variable
	dbg="$dbg -DDBGCERR -DDBGERR -DDBGFIN -DDBGFUNC -DDBGLOG -DDBGMSG -DDBGTEMP"
	dbg="$dbg -DPKTDUMP -DDUMP_STREAM"
	dbg="$dbg -Wno-error=unused-variable"
	"${MAKEJ[@]}" DBG_OPT="$dbg"
}

mOS_compile_samples() {
	local d fmt

	if [ "$mOS_FLAVOR" = dpdk ]; then
		# NOTE: the original command in setup.sh is wrong with "-Wl,$(sh cat .../ldflags.txt)"
		fmt="$(printf 's:__IO_LIB_ARGS:LIBS    += -m64 -g -pthread -lrt -march=native -Wl,-export-dynamic -L../../drivers/dpdk/lib -Wl,-lnuma -Wl,-lmtcp -Wl,-lpthread -Wl,-lrt -Wl,-ldl $(shell cat ../../drivers/dpdk/lib/ldflags.txt):g')"
	elif [ "$mOS_FLAVOR" = pcap ]; then
		fmt=$(printf 's/__IO_LIB_ARGS/GCC_OPT += -D__thread="" -DBE_RESILIENT_TO_PACKET_DROP\\nINC += -DENABLE_PCAP\\nLIBS += -lpcap/g')
	else
		__errmsg "unknown mOS_FLAVOR: $mOS_FLAVOR"
		return 1
	fi

	for d in "$PKG_BUILD_DIR/samples"/*; do
		if [ -f "$d/Makefile.in" ] && grep -q __IO_LIB_ARGS "$d/Makefile.in"; then
			cp "$d/Makefile.in" "$d/Makefile"
			sed -i -e "$fmt" "$d/Makefile"

			__errmsg "compiling $d"
			cd "$d"
			"${MAKEJ[@]}"
		fi
	done
}

staging() {
	true
}

install() {
	true
}

install_post() {
	__errmsg "
Docs on configuration file: $PKG_SOURCE_DIR/docs/man/mtcp_init

Preparation for running with DPDK packet IO

 - preserve and mount hugepages
 - load uio driver and bind devices to it
"
}
