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
PKG_VERSION=2.10.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://openvswitch.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=96acec3ff824b412f7c91ea585c0e119
PKG_DEPENDS=openssl
PKG_PLATFORM=linux

. "$PWD/env.sh"
STRIP=()

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# no autostart on boot
	patch -p1 <<"EOF"
--- a/rhel/openvswitch.spec.orig	2019-10-11 14:27:23.562611813 +0000
+++ b/rhel/openvswitch.spec	2019-10-11 14:37:58.857525470 +0000
@@ -170,7 +170,7 @@ fi
 
 # Ensure all required services are set to run
 /sbin/chkconfig --add openvswitch
-/sbin/chkconfig openvswitch on
+/sbin/chkconfig openvswitch off
 
 %post selinux-policy
 /usr/sbin/semodule -i %{_datadir}/selinux/packages/%{name}/openvswitch-custom.pp &> /dev/null || :

EOF

	patch -p0 <<"EOF"
--- rhel/openvswitch-kmod-fedora.spec.orig	2019-12-02 09:03:51.707248599 +0000
+++ rhel/openvswitch-kmod-fedora.spec	2019-12-02 09:03:57.601258652 +0000
@@ -10,8 +10,6 @@
 
 %global debug_package %{nil}
 
-#%define kernel 3.1.5-1.fc16.x86_64
-#define kernel %{kernel_source}
 %{?kversion:%define kernel %kversion}
 
 Name: openvswitch-kmod
@@ -25,6 +25,10 @@ Version: 2.9.6
 License: GPLv2
 Release: 1%{?dist}
 Source: openvswitch-%{version}.tar.gz
+Patch0: compat-add-SCTP-netfilter-states-for-older-kernels.patch
+Patch1: compat-Fix-ipv6_dst_lookup-build-error.patch
+Patch2: compat-Backport-ipv6_stub-change.patch
+Patch3: ofproto-dpif-fix-xcache-mem-leak-in-nxt_resume.patch
 #Source1: openvswitch-init
 Buildroot: /tmp/openvswitch-xen-rpm
 
@@ -35,6 +36,7 @@ traffic. This package contains the kerne
 
 %prep
-%setup -q -n openvswitch-%{version}
+%autosetup -p1 -n openvswitch-%{version}
+autoreconf --verbose --force --install
 
 %build
 %configure --with-linux=/lib/modules/%{kernel}/build --enable-ssl
--- rhel/openvswitch-fedora.spec.orig	2019-12-02 09:03:49.824245387 +0000
+++ rhel/openvswitch-fedora.spec	2019-12-02 09:04:03.224268244 +0000
@@ -66,6 +66,10 @@ Version: 2.9.6
 License: ASL 2.0 and LGPLv2+ and SISSL
 Release: 1%{?dist}
 Source: http://openvswitch.org/releases/%{name}-%{version}.tar.gz
+Patch0: compat-add-SCTP-netfilter-states-for-older-kernels.patch
+Patch1: compat-Fix-ipv6_dst_lookup-build-error.patch
+Patch2: compat-Backport-ipv6_stub-change.patch
+Patch3: ofproto-dpif-fix-xcache-mem-leak-in-nxt_resume.patch
 
 BuildRequires: autoconf automake libtool
 BuildRequires: systemd-units openssl openssl-devel
@@ -215,6 +216,7 @@ Docker network plugins for OVN.
 
 %prep
-%setup -q
+%autosetup -p1
+autoreconf --verbose --force --install
 
 %build
 %configure \
EOF

	# Cherry-picked from 8c7130da98c55bdf13eae62b5250434f8dfd366b
	cat >rhel/compat-add-SCTP-netfilter-states-for-older-kernels.patch <<"EOF"
From ff0c567cbf80c9cb215e394d4681c205090a08d2 Mon Sep 17 00:00:00 2001
From: Aaron Conole <aconole@redhat.com>
Date: Tue, 21 May 2019 14:16:30 -0400
Subject: [PATCH] compat: add SCTP netfilter states for older kernels

Bake in the SCTP states from the kernel UAPI.  This means an older
revision of the kernel headers won't interfere with the SCTP display
enhancement.  Additionally, if a newer version is available, or if
x-compiling the datapath module we defer to that version (since this
is just meant to provide the missing definitions).

This will be used in a future commit.

Signed-off-by: Aaron Conole <aconole@redhat.com>
Signed-off-by: Ben Pfaff <blp@ovn.org>
---
 acinclude.m4                                | 33 ++++++++++++++++++++-
 configure.ac                                |  1 +
 include/linux/automake.mk                   |  1 +
 include/linux/netfilter/nf_conntrack_sctp.h | 26 ++++++++++++++++
 4 files changed, 60 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_sctp.h

diff --git a/acinclude.m4 b/acinclude.m4
index 7c67fe325..e8c2296f2 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -204,7 +204,38 @@ AC_DEFUN([OVS_CHECK_LINUX_TC], [
         int x = TCA_PEDIT_KEY_EX_HDR_TYPE_UDP;
     ])],
     [AC_DEFINE([HAVE_TCA_PEDIT_KEY_EX_HDR_TYPE_UDP], [1],
-               [Define to 1 if TCA_PEDIT_KEY_EX_HDR_TYPE_UDP is avaiable.])])
+               [Define to 1 if TCA_PEDIT_KEY_EX_HDR_TYPE_UDP is available.])])
+
+  AC_COMPILE_IFELSE([
+    AC_LANG_PROGRAM([#include <linux/tc_act/tc_skbedit.h>], [
+        int x = TCA_SKBEDIT_FLAGS;
+    ])],
+    [AC_DEFINE([HAVE_TCA_SKBEDIT_FLAGS], [1],
+               [Define to 1 if TCA_SKBEDIT_FLAGS is available.])])
+])
+
+dnl OVS_CHECK_LINUX_SCTP_CT
+dnl
+dnl Checks for kernels which need additional SCTP state
+AC_DEFUN([OVS_CHECK_LINUX_SCTP_CT], [
+  AC_COMPILE_IFELSE([
+    AC_LANG_PROGRAM([#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
+#include <linux/netfilter/nf_conntrack_common.h>
+#include <linux/netfilter/nf_conntrack_sctp.h>], [
+        int x = SCTP_CONNTRACK_HEARTBEAT_SENT;
+    ])],
+    [AC_DEFINE([HAVE_SCTP_CONNTRACK_HEARTBEATS], [1],
+               [Define to 1 if SCTP_CONNTRACK_HEARTBEAT_SENT is available.])])
+])
+
+dnl OVS_FIND_DEPENDENCY(FUNCTION, SEARCH_LIBS, NAME_TO_PRINT)
+dnl
+dnl Check for a function in a library list.
+AC_DEFUN([OVS_FIND_DEPENDENCY], [
+  AC_SEARCH_LIBS([$1], [$2], [], [
+    AC_MSG_ERROR([unable to find $3, install the dependency package])
+  ])
 ])
 
 dnl OVS_CHECK_DPDK
diff --git a/configure.ac b/configure.ac
index 9c5e4d868..3d8e8d763 100644
--- a/configure.ac
+++ b/configure.ac
@@ -184,6 +184,7 @@ AC_ARG_VAR(KARCH, [Kernel Architecture String])
 AC_SUBST(KARCH)
 OVS_CHECK_LINUX
 OVS_CHECK_LINUX_TC
+OVS_CHECK_LINUX_SCTP_CT
 OVS_CHECK_DPDK
 OVS_CHECK_PRAGMA_MESSAGE
 AC_SUBST([OVS_CFLAGS])
diff --git a/include/linux/automake.mk b/include/linux/automake.mk
index b464fe0f5..e9f5deadf 100644
--- a/include/linux/automake.mk
+++ b/include/linux/automake.mk
@@ -1,4 +1,5 @@
 noinst_HEADERS += \
+	include/linux/netfilter/nf_conntrack_sctp.h \
 	include/linux/pkt_cls.h \
 	include/linux/tc_act/tc_pedit.h \
 	include/linux/tc_act/tc_tunnel_key.h \
diff --git a/include/linux/netfilter/nf_conntrack_sctp.h b/include/linux/netfilter/nf_conntrack_sctp.h
new file mode 100644
index 000000000..03b659052
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_sctp.h
@@ -0,0 +1,26 @@
+#ifndef __LINUX_NETFILTER_CONNTRACK_SCTP_WRAPPER_H
+#define __LINUX_NETFILTER_CONNTRACK_SCTP_WRAPPER_H 1
+
+#if defined(__KERNEL__) || defined(HAVE_SCTP_CONNTRACK_HEARTBEATS)
+#include_next <linux/netfilter/nf_conntrack_sctp.h>
+#else
+
+/* These are the states defined in the kernel UAPI for connection
+ * tracking. */
+enum sctp_conntrack {
+	SCTP_CONNTRACK_NONE,
+	SCTP_CONNTRACK_CLOSED,
+	SCTP_CONNTRACK_COOKIE_WAIT,
+	SCTP_CONNTRACK_COOKIE_ECHOED,
+	SCTP_CONNTRACK_ESTABLISHED,
+	SCTP_CONNTRACK_SHUTDOWN_SENT,
+	SCTP_CONNTRACK_SHUTDOWN_RECD,
+	SCTP_CONNTRACK_SHUTDOWN_ACK_SENT,
+	SCTP_CONNTRACK_HEARTBEAT_SENT,
+	SCTP_CONNTRACK_HEARTBEAT_ACKED,
+	SCTP_CONNTRACK_MAX
+};
+
+#endif
+
+#endif
EOF

	# Cherry-picked from ab78cc673ebf8e13558fdde459d74538e8cf0760
	cat >rhel/compat-Fix-ipv6_dst_lookup-build-error.patch <<"EOF"
From beb5bb0689872befe3a183544911249388b24683 Mon Sep 17 00:00:00 2001
From: Yi-Hung Wei <yihung.wei@gmail.com>
Date: Wed, 29 Apr 2020 14:25:50 -0700
Subject: [PATCH 1/2] compat: Fix ipv6_dst_lookup build error

The geneve/vxlan compat code base invokes ipv6_dst_lookup() which is
recently replaced by ipv6_dst_lookup_flow() in the stable kernel tree.

This causes travis build failure:
    * https://travis-ci.org/github/openvswitch/ovs/builds/681084038

This patch updates the backport logic to invoke the right function.

Related patch in
    git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

b9f3e457098e ("net: ipv6_stub: use ip6_dst_lookup_flow instead of
               ip6_dst_lookup")

Signed-off-by: Yi-Hung Wei <yihung.wei@gmail.com>
Signed-off-by: William Tu <u9012063@gmail.com>
---
 acinclude.m4                   |  3 +++
 datapath/linux/compat/geneve.c | 11 +++++++----
 datapath/linux/compat/vxlan.c  | 14 ++++++++------
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index e8c2296f2..1649301c9 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -491,7 +491,10 @@ AC_DEFUN([OVS_CHECK_LINUX_COMPAT], [
 
   OVS_GREP_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_dst_lookup.*net],
                   [OVS_DEFINE([HAVE_IPV6_DST_LOOKUP_NET])])
+  OVS_GREP_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_dst_lookup_flow.*net],
+                  [OVS_DEFINE([HAVE_IPV6_DST_LOOKUP_FLOW_NET])])
   OVS_GREP_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_stub])
+  OVS_GREP_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_dst_lookup_flow])
 
   OVS_GREP_IFELSE([$KSRC/include/linux/err.h], [ERR_CAST])
   OVS_GREP_IFELSE([$KSRC/include/linux/err.h], [IS_ERR_OR_NULL])
diff --git a/datapath/linux/compat/geneve.c b/datapath/linux/compat/geneve.c
index 435a23fb7..d51c2c2ad 100644
--- a/datapath/linux/compat/geneve.c
+++ b/datapath/linux/compat/geneve.c
@@ -939,14 +939,17 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 			return dst;
 	}
 
-#ifdef HAVE_IPV6_DST_LOOKUP_NET
+#if defined(HAVE_IPV6_DST_LOOKUP_FLOW_NET)
+	if (ipv6_stub->ipv6_dst_lookup_flow(geneve->net, gs6->sock->sk, &dst,
+                                            fl6)) {
+#elif defined(HAVE_IPV6_DST_LOOKUP_FLOW)
+	if (ipv6_stub->ipv6_dst_lookup_flow(gs6->sock->sk, &dst, fl6)) {
+#elif defined(HAVE_IPV6_DST_LOOKUP_NET)
 	if (ipv6_stub->ipv6_dst_lookup(geneve->net, gs6->sock->sk, &dst, fl6)) {
-#else
-#ifdef HAVE_IPV6_STUB
+#elif defined(HAVE_IPV6_STUB)
 	if (ipv6_stub->ipv6_dst_lookup(gs6->sock->sk, &dst, fl6)) {
 #else
 	if (ip6_dst_lookup(gs6->sock->sk, &dst, fl6)) {
-#endif
 #endif
 		netdev_dbg(dev, "no route to %pI6\n", &fl6->daddr);
 		return ERR_PTR(-ENETUNREACH);
diff --git a/datapath/linux/compat/vxlan.c b/datapath/linux/compat/vxlan.c
index b96cc7de0..47e148db8 100644
--- a/datapath/linux/compat/vxlan.c
+++ b/datapath/linux/compat/vxlan.c
@@ -962,17 +962,19 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
 
-#ifdef HAVE_IPV6_DST_LOOKUP_NET
-	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
-					 sock6->sock->sk,
+#if defined(HAVE_IPV6_DST_LOOKUP_FLOW_NET)
+	err = ipv6_stub->ipv6_dst_lookup_flow(vxlan->net, sock6->sock->sk,
+					      &ndst, &fl6);
+#elif defined(HAVE_IPV6_DST_LOOKUP_FLOW)
+	err = ipv6_stub->ipv6_dst_lookup_flow(sock6->sock->sk, &ndst, &fl6);
+#elif defined(HAVE_IPV6_DST_LOOKUP_NET)
+	err = ipv6_stub->ipv6_dst_lookup(vxlan->net, sock6->sock->sk,
 					 &ndst, &fl6);
-#else
-#ifdef HAVE_IPV6_STUB
+#elif defined(HAVE_IPV6_STUB)
 	err = ipv6_stub->ipv6_dst_lookup(vxlan->vn6_sock->sock->sk,
 					 &ndst, &fl6);
 #else
 	err = ip6_dst_lookup(vxlan->vn6_sock->sock->sk, &ndst, &fl6);
-#endif
 #endif
 	if (err < 0)
 		return ERR_PTR(err);
EOF

	# Cherry-picked from 28f52edd7f6978fcd97442312122543bae32597d
	cat >rhel/compat-Backport-ipv6_stub-change.patch <<"EOF"
From 6f17d3feba2509673c13f164b72eb7c71d695290 Mon Sep 17 00:00:00 2001
From: Greg Rose <gvrose8192@gmail.com>
Date: Thu, 21 May 2020 14:54:03 -0700
Subject: [PATCH 2/2] compat: Backport ipv6_stub change

A patch backported to the Linux stable 4.14 tree and present in the
latest stable 4.14.181 kernel breaks ipv6_stub usage.

The commit is
8ab8786f78c3 ("net ipv6_stub: use ip6_dst_lookup_flow instead of ip6_dst_lookup").

Create the compat layer define to check for it and fixup usage in vxlan
and geneve modules.

Passes Travis here:
https://travis-ci.org/github/gvrose8192/ovs-experimental/builds/689798733

Signed-off-by: Greg Rose <gvrose8192@gmail.com>
Signed-off-by: William Tu <u9012063@gmail.com>
---
 acinclude.m4                   |  5 +++++
 datapath/linux/compat/geneve.c | 11 ++++++++++-
 datapath/linux/compat/vxlan.c  | 18 +++++++++++++++++-
 3 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index 1649301c9..f556a7ea0 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -489,6 +489,11 @@ AC_DEFUN([OVS_CHECK_LINUX_COMPAT], [
   OVS_GREP_IFELSE([$KSRC/arch/x86/include/asm/checksum_32.h], [src_err,],
                   [OVS_DEFINE([HAVE_CSUM_COPY_DBG])])
 
+  OVS_GREP_IFELSE([$KSRC/include/net/ip6_fib.h], [rt6_get_cookie],
+                  [OVS_DEFINE([HAVE_RT6_GET_COOKIE])])
+
+  OVS_FIND_FIELD_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_stub],
+                        [dst_entry])
   OVS_GREP_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_dst_lookup.*net],
                   [OVS_DEFINE([HAVE_IPV6_DST_LOOKUP_NET])])
   OVS_GREP_IFELSE([$KSRC/include/net/addrconf.h], [ipv6_dst_lookup_flow.*net],
diff --git a/datapath/linux/compat/geneve.c b/datapath/linux/compat/geneve.c
index d51c2c2ad..bdcc6ce2d 100644
--- a/datapath/linux/compat/geneve.c
+++ b/datapath/linux/compat/geneve.c
@@ -939,7 +939,16 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 			return dst;
 	}
 
-#if defined(HAVE_IPV6_DST_LOOKUP_FLOW_NET)
+#if defined(HAVE_IPV6_STUB_WITH_DST_ENTRY) && defined(HAVE_IPV6_DST_LOOKUP_FLOW)
+#ifdef HAVE_IPV6_DST_LOOKUP_FLOW_NET
+	dst = ipv6_stub->ipv6_dst_lookup_flow(geneve->net, gs6->sock->sk, fl6,
+					      NULL);
+#else
+	dst = ipv6_stub->ipv6_dst_lookup_flow(gs6->sock->sk, fl6,
+					      NULL);
+#endif
+	if (IS_ERR(dst)) {
+#elif defined(HAVE_IPV6_DST_LOOKUP_FLOW_NET)
 	if (ipv6_stub->ipv6_dst_lookup_flow(geneve->net, gs6->sock->sk, &dst,
                                             fl6)) {
 #elif defined(HAVE_IPV6_DST_LOOKUP_FLOW)
diff --git a/datapath/linux/compat/vxlan.c b/datapath/linux/compat/vxlan.c
index 47e148db8..69837fed3 100644
--- a/datapath/linux/compat/vxlan.c
+++ b/datapath/linux/compat/vxlan.c
@@ -941,7 +941,10 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	bool use_cache = (dst_cache && ip_tunnel_dst_cache_usable(skb, info));
 	struct dst_entry *ndst;
 	struct flowi6 fl6;
+#if !defined(HAVE_IPV6_STUB_WITH_DST_ENTRY) || \
+    !defined(HAVE_IPV6_DST_LOOKUP_FLOW)
 	int err;
+#endif
 
 	if (!sock6)
 		return ERR_PTR(-EIO);
@@ -962,7 +965,15 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
 
-#if defined(HAVE_IPV6_DST_LOOKUP_FLOW_NET)
+#if defined(HAVE_IPV6_STUB_WITH_DST_ENTRY) && defined(HAVE_IPV6_DST_LOOKUP_FLOW)
+#ifdef HAVE_IPV6_DST_LOOKUP_FLOW_NET
+	ndst = ipv6_stub->ipv6_dst_lookup_flow(vxlan->net, sock6->sock->sk,
+					       &fl6, NULL);
+#else
+	ndst = ipv6_stub->ipv6_dst_lookup_flow(sock6->sock->sk, &fl6, NULL);
+#endif
+	if (unlikely(IS_ERR(ndst))) {
+#elif defined(HAVE_IPV6_DST_LOOKUP_FLOW_NET)
 	err = ipv6_stub->ipv6_dst_lookup_flow(vxlan->net, sock6->sock->sk,
 					      &ndst, &fl6);
 #elif defined(HAVE_IPV6_DST_LOOKUP_FLOW)
@@ -976,8 +987,13 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 #else
 	err = ip6_dst_lookup(vxlan->vn6_sock->sock->sk, &ndst, &fl6);
 #endif
+#if defined(HAVE_IPV6_STUB_WITH_DST_ENTRY) && defined(HAVE_IPV6_DST_LOOKUP_FLOW)
+		return ERR_PTR(-ENETUNREACH);
+	}
+#else
 	if (err < 0)
 		return ERR_PTR(err);
+#endif
 
 	*saddr = fl6.saddr;
 	if (use_cache)
EOF

	cat >rhel/ofproto-dpif-fix-xcache-mem-leak-in-nxt_resume.patch <<"EOF"
From 6e56458229d81aa48cc0c7e2f4d03af23733f0ba Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Tue, 29 Dec 2020 12:04:27 +0800
Subject: [PATCH] ofproto-dpif: fix xcache mem leak in nxt_resume

Fixes: 72700fe0 ("ofproto-dpif: Fix NXT_RESUME flow stats")
Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 ofproto/ofproto-dpif.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 6ad7b85fc..51fd0f463 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -5117,6 +5117,7 @@ nxt_resume(struct ofproto *ofproto_,
     /* Clean up. */
     ofpbuf_uninit(&odp_actions);
     dp_packet_uninit(&packet);
+    xlate_cache_uninit(&xcache);
 
     return error;
 }
EOF
}

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
ovs_kversion="3.10.0-1160.6.1.el7.yn20201125.x86_64"
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

build_rpm() {
	local topdir="$PKG_BUILD_DIR/rpmbuild"
	local bn="$PKG_NAME-$PKG_VERSION"

	unset PKG_CONFIG_PATH

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
		--without check \
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
