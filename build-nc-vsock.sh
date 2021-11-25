#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Usage
#
#   nc-vsock -l svm_port # VMADDR_CID_ANY
#   nc-vsock -l svm_port -t host port
#   nc-vsock svm_cid svm_port
#
# nc-vsock "supports tunneling over TCP on the listen side".  It connects to
# the host:port and use dup2 to make it stdin/stdout
#
# On the listen side, it can only serve one connection
#
# Special, /usr/include/linux/vm_sockets.h
#
#  - VMADDR_CID_ANY (-1U) means any address for binding
#  - VMADDR_CID_HYPERVISOR (0) is reserved for services built into the hypervisor
#  - VMADDR_CID_LOCAL (1) This was VMADDR_CID_RESERVED, but even VMCI doesn't use it anymore
#  - VMADDR_CID_HOST (2) is the well-known address of the host
#
#  - VMADDR_PORT_ANY (-1U) bind to any available port
#
# Let guest connect to VMADDR_CID_HOST
#
# - https://man7.org/linux/man-pages/man7/vsock.7.html
# - http://kvmonz.blogspot.com/p/knowledge-using-vsock.html
#
PKG_NAME=nc-vsock
PKG_VERSION=1.0.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/stefanha/nc-vsock/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=48e707e07ca53d4befc47dd68bec6608
PKG_SOURCE_UNTAR_FIXUP=1

# make it static for use inside virtual machine
o_build_static=1
. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"

IOCTL_VM_SOCKETS_GET_LOCAL_CID on /dev/vsock

--- nc-vsock.c.orig	2021-12-03 03:15:06.746676239 +0000
+++ nc-vsock.c	2021-12-03 03:25:02.856305204 +0000
@@ -27,6 +27,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/select.h>
+#include <sys/ioctl.h>
 #include <netdb.h>
 #include <linux/vm_sockets.h>
 
@@ -175,6 +176,12 @@ static int vsock_connect(const char *cid
 	return fd;
 }
 
+static void usage(char **argv)
+{
+	fprintf(stderr, "usage: %s [-l <port> [-t <dst> <dstport>] | <cid> <port>]\n", argv[0]);
+	fprintf(stderr, "usage: %s -i\n", argv[0]);
+}
+
 static int get_remote_fd(int argc, char **argv)
 {
 	if (argc >= 3 && strcmp(argv[1], "-l") == 0) {
@@ -202,7 +209,7 @@ static int get_remote_fd(int argc, char
 	} else if (argc == 3) {
 		return vsock_connect(argv[1], argv[2]);
 	} else {
-		fprintf(stderr, "usage: %s [-l <port> [-t <dst> <dstport>] | <cid> <port>]\n", argv[0]);
+		usage(argv);
 		return -1;
 	}
 }
@@ -311,8 +318,38 @@ static void main_loop(int remote_fd)
 	}
 }
 
+static int get_local_cid(unsigned int *cid)
+{
+	int fd;
+	int r;
+
+	fd = open("/dev/vsock", O_RDONLY);
+	if (fd < 0) {
+		perror("open /dev/vsock");
+		return -1;
+	}
+	r = ioctl(fd, IOCTL_VM_SOCKETS_GET_LOCAL_CID, cid);
+	if (r != 0) {
+		perror("ioctl");
+		return -1;
+	}
+	return 0;
+}
+
 int main(int argc, char **argv)
 {
+	if (argc == 2 && strcmp(argv[1], "-i") == 0) {
+		unsigned int cid;
+		int r;
+
+		r = get_local_cid(&cid);
+		if (r != 0) {
+			return -1;
+		}
+		printf("%d\n", cid);
+		return 0;
+	}
+
 	int remote_fd = get_remote_fd(argc, argv);
 
 	if (remote_fd < 0) {
EOF
}

configure() {
	true
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"

	mkdir -p "$bindir"
	cp "$PKG_BUILD_DIR/nc-vsock" "$bindir/nc-vsock"
}
