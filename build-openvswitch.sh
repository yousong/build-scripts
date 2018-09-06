#!/bin/bash -e
#
# Copyright 2015-2017 (c) Yousong Zhou
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
PKG_NAME=openvswitch
PKG_VERSION=2.10.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://openvswitch.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=33a55c9bac1fcaa8842f84a175e50800
PKG_DEPENDS=openssl
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
ovs_enable_kmod=1

if [ "$ovs_enable_kmod" -gt 0 ]; then
	ovs_with_kmod="/lib/modules/$(uname -r)/build"
	if [ ! -d "$ovs_with_kmod" ]; then
		__errmsg "openvswitch: cannot find kernel build dir $ovs_with_kmod"
		false
	fi
	CONFIGURE_ARGS+=(
		--with-linux="$ovs_with_kmod"
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

	build_staging 'install'
	if [ "$ovs_enable_kmod" -gt 0 ]; then
		build_staging modules_install
	fi
	cat >"$ds0/ovs-wrapper" <<-EOF
		#/usr/bin/env bash
		case "\$0" in
		    *ovs-ctl) "$ds1/ovs-ctl" "\$@" ;;
		    *ovs-kmod-ctl) "$ds1/ovs-kmod-ctl" "\$@" ;;
		    *ovn-ctl) "$ds1/ovn-ctl" "\$@" ;;
		esac
	EOF
	chmod a+x "$ds0/ovs-wrapper"
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovs-ctl"
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovs-kmod-ctl"
	ln -sf "../share/openvswitch/scripts/ovs-wrapper" "$d0/bin/ovn-ctl"
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
