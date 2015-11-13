#!/bin/sh -e
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
PKG_VERSION="2.3.2"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://openvswitch.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="5a5739ed82f1accac1c2d8d7553dc88f"

. "$PWD/env.sh"

if ! os_is_linux; then
	__errmsg "we build Open vSwitch only on Linux"
	exit 1
fi

KBUILD_DIR="/lib/modules/$(uname -r)/build"
CONFIGURE_ARGS="					\\
	--with-linux="$KBUILD_DIR"		\\
	--enable-ndebug					\\
"

build_pre() {
	cd "$PKG_BUILD_DIR"

    if [ ! -x "$BUILD_DIR/configure" ]; then
        __errmsg "Bootstrapping a configure script"
        ./boot.sh
    fi
}

install_do() {
	cd "$PKG_BUILD_DIR"
	make DESTDIR="$_PKG_STAGING_DIR" install
    #sudo make modules_install
	cp "$_PKG_STAGING_DIR/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

main
