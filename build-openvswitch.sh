#!/bin/bash -e
#
# Copyright 2015-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# On building kernel module
#
#  - Build on CentOS 7 will not work.  CentOS 7 already ships a
#    openvswitch.ko module with GRE and VXLAN support (kernel 3.10).
#  - Build on Debian requires to install
#
#       sudo apt-get install "linux-headers-$(uname -r)"
#
#    OVS has checks to determine if the vxlan module has required features
#    available.  If all rquired features are in the module then only OVS
#    uses it.
#
#    Search for `USE_KERNEL_TUNNEL_API` in the source code.
#
#    - [ovs-discuss] VxLAN kernel module.
#      http://openvswitch.org/pipermail/discuss/2015-March/016947.html
#
#    You may need to upgrade the kernel
#
#    - skb_copy_ubufs() not exported by the Debian Linux kernel 3.2.57-3,
#      https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=746602
#
#  - See INSTALL in openvswtich source tree for details.
#
# On hot upgrade and ovs-ctl
#
#     sudo apt-get install uuid-runtime
#     /usr/local/share/openvswitch/scripts/ovs-ctl force-reload-kmod --system-id=random
#

. "$PWD/utils-openvswitch.sh"

PKG_VERSION="$PKG_openvswitch_VERSION"
PKG_SOURCE="$PKG_openvswitch_SOURCE"
PKG_SOURCE_URL="$PKG_openvswitch_SOURCE_URL"
PKG_SOURCE_MD5SUM="$PKG_openvswitch_SOURCE_MD5SUM"

PKG_NAME=openvswitch
PKG_DEPENDS="libunwind openssl unbound"
PKG_PLATFORM=linux

. "$PWD/env.sh"
STRIP=()

# to disable building python-related code
#CONFIGURE_VARS+=(
#	ovs_cv_python=no
#)

# --enable-ndebug, disable debugging features for max performance
# --with-debug, only takes effect for msvc by passing -O0
#
CONFIGURE_ARGS+=(
	--enable-shared
	--enable-ndebug
)

# EXTRA_CFLAGS+=(-g)

# - What Linux kernel versions does each Open vSwitch release work with?
# - Are all features available with all datapaths?
#   https://github.com/openvswitch/ovs/blob/master/Documentation/faq/releases.rst
# - where most checks are located,
#   https://github.com/openvswitch/ovs/blob/master/acinclude.m4
#   https://github.com/openvswitch/ovs/blob/master/m4/openvswitch.m4
#
# Configure options
#
#	--with-linux, the Linux kernel build directory
#	--with-linux-source, the Linux kernel source directory
#	--with-dpdk, the DPDK build directory
#
# With DPDK 17.05.1, it's possible that both ovs-vswitchd and libopenvswitch.so
# links to libdpdk.so and constructors were called multiple times at dynamic
# link stage causing the program fail early
#
#	EAL: VFIO_RESOURCE_LIST tailq is already registered
#	PANIC in tailqinitfn_rte_vfio_tailq():
#	Cannot initialize tailq: VFIO_RESOURCE_LIST
#	6: [ovs-vswitchd() [0x4284d1]]
#	5: [/lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0x90) [0x7f93a666ce40]]
#
ovs_enable_dpdk=0
ovs_enable_kmod=0
if [ -z "$ovs_kversion" ]; then
	ovs_kversion="$(uname -r)"
fi
ovs_kbuild_dir=

if [ "$ovs_enable_kmod" -gt 0 ]; then
	ovs_with_kmod="/lib/modules/$ovs_kversion/build"
	if [ -d "$ovs_with_kmod" ]; then
		ovs_kbuild_dir="$ovs_with_kmod"
	else
		ovs_kbuild_dir="/usr/src/kernels/$ovs_kversion"
		if [ ! -d "$ovs_kbuild_dir" ]; then
			__errmsg "openvswitch: cannot find kernel build dir $ovs_kbuild_dir, or $ovs_with_kmod"
			false
		fi
	fi
	CONFIGURE_ARGS+=(
		--with-linux="$ovs_kbuild_dir"
	)
	MAKE_ENVS+=(
		INSTALL_MOD_PATH=""$PKG_STAGING_DIR$INSTALL_PREFIX""
	)
fi

if [ "$ovs_enable_dpdk" -gt 0 ]; then
	ovs_with_dpdk="$("$TOPDIR/build-dpdk.sh" dpdk_prefix)"
	if [ ! -d "$ovs_with_dpdk" ]; then
		__errmsg "openvswitch: cannot find dpdk dir dir $ovs_with_dpdk"
		false
	fi
	CONFIGURE_ARGS+=(
		--with-dpdk="$ovs_with_dpdk"
	)
	PKG_DEPENDS="$PKG_DEPENDS dpdk"
fi

staging() {
	local d0="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local d1="$INSTALL_PREFIX"
	local ds0="$d0/share/openvswitch/scripts"
	local ds1="$d1/share/openvswitch/scripts"
	local ds2="$d1/share/ovn/scripts"

	build_staging 'install'
	if [ "$ovs_enable_kmod" -gt 0 ]; then
		build_staging modules_install
	fi
	cat >"$ds0/ovs-wrapper" <<-EOF
		#/usr/bin/env bash
		case "\$0" in
		    *ovs-ctl) "$ds1/ovs-ctl" "\$@" ;;
		    *ovs-kmod-ctl) "$ds1/ovs-kmod-ctl" "\$@" ;;
		    *ovn-ctl) "$ds2/ovn-ctl" "\$@" ;;
		esac
	EOF
	chmod a+x "$ds0/ovs-wrapper"
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovs-ctl"
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovs-kmod-ctl"
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovn-ctl"
}

build_rpm() {
	local topdir="$PKG_BUILD_DIR/rpmbuild"
	local bn="$PKG_NAME-$PKG_VERSION"

	cd "$PKG_SOURCE_DIR/.."
	mkdir -p "$topdir/SOURCES"
	tar czf "$topdir/SOURCES/$PKG_SOURCE" \
		--exclude "$bn/rpmbuild" \
		"$bn" >"$topdir/SOURCES/$bn.tar.gz"
	find "$PKG_SOURCE_DIR/rhel" -name '*.patch' | while read f; do
		cp "$f" "$topdir/SOURCES"
	done

	cpdir "$PKG_SOURCE_DIR/rhel" "$topdir/SPECS"
	cd "$topdir/SPECS"
	# Use openvswitch-fedora as suggested by
	# http://docs.openvswitch.org/en/latest/intro/install/fedora/
	#
	#sudo yum-builddep openvswitch-fedora.spec
	rpmbuild \
		-bb \
		-D "%_topdir $topdir" \
		openvswitch-fedora.spec

	# Setting %kernel based on value of %kversion at the top of spec file
	# can get reverted when applying patches.  That's way we set %kernel
	# explicitly
	#
	# Also it's important that we remove the comment lines placed ahead of
	# setting %kernel in the spec file, otherwise %kernel can always take
	# value 3.1.5-1.fc16.x86_64
	sed -i -e 's/openvswitch-kmod/kmod-openvswitch/g' \
		openvswitch-kmod-fedora.spec
	sed -i -e "s:=/lib/modules/%{kernel}/build:=${ovs_kbuild_dir}:g" \
		openvswitch-kmod-fedora.spec
	rpmbuild \
		-bb \
		-D "%_topdir $topdir" \
		-D "kversion $ovs_kversion" \
		-D "kernel $ovs_kversion" \
		openvswitch-kmod-fedora.spec
}

install_post() {
	if [ -d "$ovs_with_kmod" ]; then
		__errmsg "
Note that different builds of openvswitch may have different --prefix hardcoded
in.  You may not want to invoke 'ovs-ctl force-reload-kmod' against a running
instance configured with different --prefix setting
"
	fi
}
