#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=fstools
PKG_VERSION=2019-09-20
PKG_SOURCE_VERSION=4327ed40d96c95803b2d4d09ddf997c895eea071
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/$PKG_NAME.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libubox ubus uci'
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
--- a/CMakeLists.txt.orig	2019-10-25 08:40:29.924130260 +0000
+++ b/CMakeLists.txt	2019-10-25 08:40:33.199113017 +0000
@@ -1,7 +1,7 @@
 cmake_minimum_required(VERSION 2.6)
 
 PROJECT(fs-tools C)
-ADD_DEFINITIONS(-Os -ggdb -Wall -Werror --std=gnu99 -Wmissing-declarations -Wno-format-truncation)
+ADD_DEFINITIONS(-Os -ggdb -Wall -Werror --std=gnu99 -Wmissing-declarations -Wno-self-assign)
 
 SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
 
EOF
	patch -p1 <<"EOF"
From 7fabe08177de759419456f50ab0da3596a74ebd5 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Fri, 25 Oct 2019 08:58:25 +0000
Subject: [PATCH] libblkid-tiny: ntfs: fix use-after-free

The memory pointed to by ns can be reallocated when checking mft records

Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 libblkid-tiny/ntfs.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/libblkid-tiny/ntfs.c b/libblkid-tiny/ntfs.c
index 3a9d5cb..2426e70 100644
--- a/libblkid-tiny/ntfs.c
+++ b/libblkid-tiny/ntfs.c
@@ -86,6 +86,7 @@ static int probe_ntfs(blkid_probe pr, const struct blkid_idmag *mag)
 
 	uint32_t sectors_per_cluster, mft_record_size;
 	uint16_t sector_size;
+	uint64_t volume_serial;
 	uint64_t nr_clusters, off, attr_off;
 	unsigned char *buf_mft;
 
@@ -146,15 +147,16 @@ static int probe_ntfs(blkid_probe pr, const struct blkid_idmag *mag)
 		return 1;
 
 
+	volume_serial = ns->volume_serial;
 	off = le64_to_cpu(ns->mft_cluster_location) * sector_size *
 		sectors_per_cluster;
 
 	DBG(LOWPROBE, ul_debug("NTFS: sector_size=%"PRIu16", mft_record_size=%"PRIu32", "
 			"sectors_per_cluster=%"PRIu32", nr_clusters=%"PRIu64" "
-			"cluster_offset=%"PRIu64"",
+			"cluster_offset=%"PRIu64", volume_serial=%"PRIu64"",
 			sector_size, mft_record_size,
 			sectors_per_cluster, nr_clusters,
-			off));
+			off, volume_serial));
 
 	buf_mft = blkid_probe_get_buffer(pr, off, mft_record_size);
 	if (!buf_mft)
@@ -203,9 +205,9 @@ static int probe_ntfs(blkid_probe pr, const struct blkid_idmag *mag)
 	}
 
 	blkid_probe_sprintf_uuid(pr,
-			(unsigned char *) &ns->volume_serial,
-			sizeof(ns->volume_serial),
-			"%016" PRIX64, le64_to_cpu(ns->volume_serial));
+			(unsigned char *) &volume_serial,
+			sizeof(volume_serial),
+			"%016" PRIX64, le64_to_cpu(volume_serial));
 	return 0;
 }
 
EOF

	patch -p1 <<"EOF"
From dfb0d4478abcb5460e61d57de995ab136585da7f Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Fri, 25 Oct 2019 10:39:51 +0000
Subject: [PATCH fstools] block: use fsck.fat instead of dosfsck

Dosfsck is only available when --enable-compat-symlinks was given when
configuring dosfstools.  These symlinks are not enabled in OpenWrt
dosfstools package

Suggested by Reiner Otto in FS#2408

Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 block.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/block.c b/block.c
index 39212d2..a849500 100644
--- a/block.c
+++ b/block.c
@@ -708,7 +708,7 @@ static void check_filesystem(struct probe_info *pr)
 	struct stat statbuf;
 	const char *e2fsck = "/usr/sbin/e2fsck";
 	const char *f2fsck = "/usr/sbin/fsck.f2fs";
-	const char *dosfsck = "/usr/sbin/dosfsck";
+	const char *fatfsck = "/usr/sbin/fsck.fat";
 	const char *btrfsck = "/usr/bin/btrfsck";
 	const char *ntfsck = "/usr/bin/ntfsfix";
 	const char *ckfs;
@@ -718,7 +718,7 @@ static void check_filesystem(struct probe_info *pr)
 		return;
 
 	if (!strncmp(pr->type, "vfat", 4)) {
-		ckfs = dosfsck;
+		ckfs = fatfsck;
 	} else if (!strncmp(pr->type, "f2fs", 4)) {
 		ckfs = f2fsck;
 	} else if (!strncmp(pr->type, "ext", 3)) {
EOF
}
