#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=dtc
PKG_VERSION=1.5.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/dgibson/dtc/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=791645a89d4b508a9a11ee6bf7d07361

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
From eac2ad495b29f15d78daa2a7226653f36515cd7a Mon Sep 17 00:00:00 2001
From: David Gibson <david@gibson.dropbear.id.au>
Date: Mon, 25 Mar 2019 14:52:47 +1100
Subject: [PATCH] Update version.lds again

Yet again, we've added several functions to libfdt that were supposed
to be exported, but forgotten to add them to the versio.lds script.
This adds them.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 libfdt/version.lds | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/libfdt/version.lds b/libfdt/version.lds
index 9f5d708..a5fe62d 100644
--- a/libfdt/version.lds
+++ b/libfdt/version.lds
@@ -66,6 +66,10 @@ LIBFDT_1.2 {
 		fdt_resize;
 		fdt_overlay_apply;
 		fdt_get_string;
+		fdt_get_max_phandle;
+		fdt_check_full;
+		fdt_setprop_placeholder;
+		fdt_property_placeholder;
 	local:
 		*;
 };
EOF
}

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	NO_PYTHON=1
)
