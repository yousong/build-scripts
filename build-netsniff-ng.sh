#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# flowtop requires libnetfilter-conntrack-dev
# curvetun requires nacl (networking and cryptography library)
#
# This package provides mz (mausezahn), flowtop, iftop, etc.
#
PKG_NAME=netsniff-ng
PKG_VERSION=0.6.1
PKG_SOURCE=$PKG_NAME-$PKG_VERSION.tar.xz
PKG_SOURCE_URL="http://pub.netsniff-ng.org/netsniff-ng/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9f9e80d97723effa2e8a575b8ab44adc
PKG_DEPENDS='ncurses libcli libnet libnl3 libpcap liburcu'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
From 68d5c16530edda781327172ca456a78092a746dc Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Tue, 27 Sep 2016 15:01:59 +0800
Subject: [PATCH 1/2] build: configure: fix checking CC containing -i option

On CentOS 6, the configure process may hang there reading stdin if the
we have CC='gcc -isystem'.  This can be reproduced with

    bash -c 'which gcc -i'

Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 configure | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/configure b/configure
index 5055654..3fb0c18 100755
--- a/configure
+++ b/configure
@@ -50,6 +50,13 @@ tools_remove()
 	TOOLS_NOBUILD=${TOOLS_NOBUILD# }
 }
 
+check_command()
+{
+	local cmd="$1"
+
+	[ "x$(which "$cmd" 2>> config.log)" == "x" ]
+}
+
 check_toolchain()
 {
 	if [ "x$CROSS_COMPILE" != "x" ] ; then
@@ -58,7 +65,7 @@ check_toolchain()
 	fi
 
 	echo -n "[*] Checking compiler $CC ... "
-	if [ "x$(which $CC 2>> config.log)" == "x" ] ; then
+	if check_command $CC ; then
 		echo "[NO]"
 		MISSING_TOOLCHAIN=1
 	else
@@ -67,7 +74,7 @@ check_toolchain()
 	fi
 
 	echo -n "[*] Checking linker $LD ... "
-	if [ "x$(which $LD 2>> config.log)" == "x" ] ; then
+	if check_command $LD ; then
 		echo "[NO]"
 		MISSING_TOOLCHAIN=1
 	else
@@ -76,7 +83,7 @@ check_toolchain()
 	fi
 
 	echo -n "[*] Checking $PKG_CONFIG ... "
-	if [ "x$(which $PKG_CONFIG 2>> config.log)" == "x" ] ; then
+	if check_command $PKG_CONFIG ; then
 		echo "[NO]"
 		MISSING_TOOLCHAIN=1
 	else
@@ -90,7 +97,7 @@ check_flex()
 {
 	echo -n "[*] Checking flex ... "
 
-	if [ "x$(which flex 2>> config.log)" == "x" ] ; then
+	if check_command flex ; then
 		echo "[NO]"
 		MISSING_DEFS=1
 		tools_remove "trafgen"
@@ -104,7 +111,7 @@ check_bison()
 {
 	echo -n "[*] Checking bison ... "
 
-	if [ "x$(which bison 2>> config.log)" == "x" ] ; then
+	if check_command bison ; then
 		echo "[NO]"
 		MISSING_DEFS=1
 		tools_remove "trafgen"
-- 
2.6.4

EOF
	patch -p1 <<"EOF"
From 9e6e63262a2f449e94ebacd73e1be9dac46afe29 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Tue, 27 Sep 2016 15:04:41 +0800
Subject: [PATCH 2/2] build: fix build on CentOS 6 by checking presence of
 several macros

Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 dev.c         | 2 ++
 proto_nlmsg.c | 4 ++++
 ring.h        | 6 +++++-
 ring_rx.c     | 4 ++++
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/dev.c b/dev.c
index 5a43643..2960976 100644
--- a/dev.c
+++ b/dev.c
@@ -385,8 +385,10 @@ const char *device_type2str(uint16_t type)
 		return "phonet";
 	case ARPHRD_PHONET_PIPE:
 		return "phonet_pipe";
+#if defined(ARPHRD_CAIF)
 	case ARPHRD_CAIF:
 		return "caif";
+#endif
 	case ARPHRD_IP6GRE:
 		return "ip6gre";
 	case ARPHRD_NETLINK:
diff --git a/proto_nlmsg.c b/proto_nlmsg.c
index 6b43335..f8993e7 100644
--- a/proto_nlmsg.c
+++ b/proto_nlmsg.c
@@ -159,7 +159,9 @@ static const char *nlmsg_family2str(uint16_t family)
 	case NETLINK_SCSITRANSPORT:	return "SCSI transports";
 	case NETLINK_ECRYPTFS:		return "ecryptfs";
 	case NETLINK_RDMA:		return "RDMA";
+#if defined(NETLINK_CRYPTO)
 	case NETLINK_CRYPTO:		return "Crypto layer";
+#endif
 	default:			return "Unknown";
 	}
 }
@@ -630,9 +632,11 @@ static void rtnl_print_route(struct nlmsghdr *hdr)
 			rta_fmt(attr, "Pref Src %s", addr2str(rtm->rtm_family,
 				RTA_DATA(attr), addr_str, sizeof(addr_str)));
 			break;
+#if defined(RTA_MARK)
 		case RTA_MARK:
 			rta_fmt(attr, "Mark 0x%x", RTA_UINT(attr));
 			break;
+#endif
 		case RTA_FLOW:
 			rta_fmt(attr, "Flow 0x%x", RTA_UINT(attr));
 			break;
diff --git a/ring.h b/ring.h
index 4153b9c..6a50f60 100644
--- a/ring.h
+++ b/ring.h
@@ -68,7 +68,11 @@ static inline uint16_t tpacket_uhdr_vlan_proto(union tpacket_uhdr *hdr, bool v3)
 
 static inline bool tpacket_has_vlan_info(union tpacket_uhdr *hdr)
 {
-	uint32_t valid = TP_STATUS_VLAN_VALID;
+	uint32_t valid = 0;
+
+#ifdef TP_STATUS_VLAN_VALID
+	valid |= TP_STATUS_VLAN_VALID;
+#endif
 
 #ifdef TP_STATUS_VLAN_TPID_VALID
 	valid |= TP_STATUS_VLAN_TPID_VALID;
diff --git a/ring_rx.c b/ring_rx.c
index f40ad2f..b6dd82d 100644
--- a/ring_rx.c
+++ b/ring_rx.c
@@ -202,12 +202,16 @@ static void join_fanout_group(int sock, uint32_t fanout_group, uint32_t fanout_t
 	if (fanout_group == 0)
 		return;
 
+#if defined(PACKET_FANOUT)
 	fanout_opt = (fanout_group & 0xffff) | (fanout_type << 16);
 
 	ret = setsockopt(sock, SOL_PACKET, PACKET_FANOUT, &fanout_opt,
 			 sizeof(fanout_opt));
 	if (ret < 0)
 		panic("Cannot set fanout ring mode!\n");
+#else
+	panic("fanout ring mode is not available!\n");
+#endif
 }
 
 void ring_rx_setup(struct ring *ring, int sock, size_t size, int ifindex,
-- 
2.6.4

EOF
}

# This is required for detection of libraries built by us, e.g. libcli etc.
CONFIGURE_VARS="$CONFIGURE_VARS				\\
	CC='gcc $EXTRA_CFLAGS $EXTRA_LDFLAGS'	\\
	LD='gcc $EXTRA_LDFLAGS'					\\
"

MAKE_VARS="$MAKE_VARS				\\
	PREFIX='$INSTALL_PREFIX'		\\
	ETCDIR='$INSTALL_PREFIX/etc'	\\
	Q=	\\
"
