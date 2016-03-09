#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
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
PKG_VERSION=2.3.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://openvswitch.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5a5739ed82f1accac1c2d8d7553dc88f
PKG_DEPENDS=openssl
PKG_PLATFORM=linux

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-shared					\\
	--enable-ndebug					\\
"

# build only userspace tools by default
#
# the Linux kernel versions against which the given versions of the Open
# vSwitch kernel module will successfully build.
#
#    1.11.x        2.6.18 to 3.8
#    2.3.x         2.6.32 to 3.14
#    2.4.x         2.6.32 to 4.0
#    2.5.x         2.6.32 to 4.3
#
# the datapath supported features from an Open vSwitch user's perspective
#
#    Feature                    Linux upstream    Linux OVS tree
#    Connection tracking        4.3               3.10
#    Tunnel - VXLAN             3.12              YES
#
# - What Linux kernel versions does each Open vSwitch release work with?
#   https://github.com/openvswitch/ovs/blob/master/FAQ.md#q-what-linux-kernel-versions-does-each-open-vswitch-release-work-with
# - Are all features available with all datapaths?
#	https://github.com/openvswitch/ovs/blob/master/FAQ.md#q-are-all-features-available-with-all-datapaths
if false; then
	KBUILD_DIR="/lib/modules/$(uname -r)/build"
	# --with-linux, the Linux kernel build directory
	# --with-linux-source, the Linux kernel source directory
	# --with-dpdk, the DPDK build directory
	CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
		--with-linux="$KBUILD_DIR"			\\
	"
fi
