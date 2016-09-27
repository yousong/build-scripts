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
PKG_VERSION=0.6.0
PKG_SOURCE=$PKG_NAME-$PKG_VERSION.tar.xz
PKG_SOURCE_URL="http://pub.netsniff-ng.org/netsniff-ng/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5bc28fc75e0e7fe41e2ec077fc527f8c
PKG_DEPENDS='ncurses libcli libnet libnl3 libpcap liburcu'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# bash -c 'which gcc -i' may hang configure process on CentOS with which
	# reading stdin (a tty device)
	patch -p0 <<"EOF"
--- configure.orig	2016-09-27 14:38:30.267918354 +0800
+++ configure	2016-09-27 14:43:19.624008919 +0800
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
EOF

	# many features are not available on CentOS
	patch -p0 <<"EOF"
--- dev.c.orig	2016-09-27 13:10:33.278266718 +0800
+++ dev.c	2016-09-27 13:10:37.578268064 +0800
@@ -360,8 +360,10 @@ const char *device_type2str(uint16_t typ
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
--- proto_nlmsg.c.orig	2016-09-27 13:09:07.802239966 +0800
+++ proto_nlmsg.c	2016-09-27 14:21:19.911595865 +0800
@@ -98,7 +98,9 @@ static const char *nlmsg_family2str(uint
 	case NETLINK_SCSITRANSPORT:	return "SCSI transports";
 	case NETLINK_ECRYPTFS:		return "ecryptfs";
 	case NETLINK_RDMA:		return "RDMA";
+#if defined(NETLINK_CRYPTO)
 	case NETLINK_CRYPTO:		return "Crypto layer";
+#endif
 	default:			return "Unknown";
 	}
 }
@@ -543,9 +545,11 @@ static void rtnl_print_route(struct nlms
 			attr_fmt(attr, "Pref Src %s", addr2str(rtm->rtm_family,
 				RTA_DATA(attr), addr_str, sizeof(addr_str)));
 			break;
+#if defined(RTA_MARK)
 		case RTA_MARK:
 			attr_fmt(attr, "Mark 0x%x", RTA_UINT(attr));
 			break;
+#endif
 		case RTA_FLOW:
 			attr_fmt(attr, "Flow 0x%x", RTA_UINT(attr));
 			break;
--- ring.h.orig	2016-09-27 13:06:54.278198174 +0800
+++ ring.h	2016-09-27 13:07:17.970205590 +0800
@@ -68,7 +68,11 @@ static inline uint16_t tpacket_uhdr_vlan
 
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
--- ring_rx.c.orig	2016-09-27 13:13:51.198328665 +0800
+++ ring_rx.c	2016-09-27 13:14:22.766338545 +0800
@@ -202,12 +202,15 @@ void join_fanout_group(int sock, uint32_
 	if (fanout_group == 0)
 		return;
 
+#if defined(PACKET_FANOUT)
 	fanout_opt = (fanout_group & 0xffff) | (fanout_type << 16);
 
 	ret = setsockopt(sock, SOL_PACKET, PACKET_FANOUT, &fanout_opt,
 			 sizeof(fanout_opt));
 	if (ret < 0)
+#endif
 		panic("Cannot set fanout ring mode!\n");
+	
 }
 
 void ring_rx_setup(struct ring *ring, int sock, size_t size, int ifindex,
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
