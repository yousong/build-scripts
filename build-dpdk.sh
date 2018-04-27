#!/bin/bash -e
#
# Copyright 2016-2017 (c) Yousong Zhou
#
# Read doc/build-sdk-quick.txt in the tarball for quick notes about the build
# system of DPDK.  Build system of DPDK may change in a substantial way so be
# careful when doing version bump or downgrade
#
# - 27. Development Kit Build System, http://dpdk.org/doc/guides/prog_guide/dev_kit_build_system.html
#
# If you are building inside an VM and get the following error, try specifying
# `-cpu host' for QEMU or building on a physical host
#
#	cc1: error: CPU you selected does not support x86-64 instruction set
#
# - [dpdk-dev] CPU does not support x86-64 instruction set,
#	http://dpdk.org/ml/archives/dev/2014-June/003748.html
#
# Building for x86_64-ivshmem-linuxapp-gcc will generate kenrel modules
# rte_kni.ko, igb_uio.ko, etc.
#
PKG_NAME=dpdk
PKG_VERSION=17.05.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://fast.dpdk.org/rel/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=15f5543490fe95bd9fef331a123abd88
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=linux

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"

dpdk_target=x86_64-native-linuxapp-gcc
dpdk_prefix="$INSTALL_PREFIX/dpdk/dpdk-$PKG_VERSION-$dpdk_target"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
Staging kmod into $(prefix)

--- mk/rte.sdkinstall.mk.orig	2017-09-01 10:38:29.003121731 +0800
+++ mk/rte.sdkinstall.mk	2017-09-01 10:38:32.371122783 +0800
@@ -54,7 +54,7 @@ export prefix ?=
 kerneldir   ?= $(prefix)/kmod
 else
 ifeq ($(RTE_EXEC_ENV),linuxapp)
-kerneldir   ?= /lib/modules/$(shell uname -r)/extra/dpdk
+kerneldir   ?= $(prefix)/lib/modules/$(shell uname -r)/extra/dpdk
 else
 kerneldir   ?= /boot/modules
 endif
EOF
}

configure() {
	local dotc="$PKG_BUILD_DIR/config/common_linuxapp"

	cd "$PKG_BUILD_DIR"
	kconfig_set_option CONFIG_RTE_BUILD_COMBINE_LIBS y "$dotc"
	kconfig_set_option CONFIG_RTE_LIBRTE_VHOST y "$dotc"
	"${MAKEJ[@]}" config "T=$dpdk_target"
}

#RTE_KERNELDIR='linux headers path'

env_fixup_extra_ldflags
MAKE_VARS=(
	EXTRA_CPPFLAGS="${EXTRA_CPPFLAGS[@]}"
	EXTRA_CFLAGS="${EXTRA_CFLAGS[@]} -fPIC"
	EXTRA_LDFLAGS="${EXTRA_LDFLAGS[@]}"
	prefix="$dpdk_prefix"
	T="$dpdk_target"
	V=1
)

dpdk_compile_examples() {
	local name="$1"
	local d="$PKG_BUILD_DIR/examples"

	if [ -n "$name" ]; then
		d="$d/$name"
	fi

	# RTE_SDK can also be "$dpdk_prefix/share/dpdk".  The examples directory
	# will be copied as part of the install-doc target.  That's why we do not
	# build there to avoid polluting the $dpdk_prefix/share/dpdk/examples
	cd "$d"
	RTE_SDK="$PKG_BUILD_DIR" \
		RTE_TARGET="$dpdk_target" \
		"${MAKEJ[@]}"
}

# Changes in build method from 2.0.0 to 2.2.0
#
# - 2.2.0 supports prefix= variable when doing compile and install.  We can use
#	the mechanism to install it to $dpdk_prefix and use it with openvswitch.
# - With 2.0.0, we'd better just use the default ./ for installation
# - Maybe T= is not needed in 2.2.0.
# - By default only static libraries will be built, and it's good for
#	simplicity.  But building libopenvswitch.so requires object files in
#	archive to be built with -fPIC
# - Openvswitch 2.4.0 is supposed to only work with DPDK 2.0.0 because it
#	requires libintel_dpdk but in DPDK 2.2.0, the name is changed to libdpdk
#
# see mk/rte.sdkinstall.mk for detailed if.else.
#
dpdk_help() {
	__errmsg "

# setup hugepage mappings

http://dpdk.readthedocs.io/en/stable/linux_gsg/sys_reqs.html#running-dpdk-applications
"
}

dpdk_prefix() {
	echo "$dpdk_prefix"
}
