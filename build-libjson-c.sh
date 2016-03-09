#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=json-c
PKG_VERSION=0.12
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://s3.amazonaws.com/json-c_releases/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3ca4bbb881dfc4017e8021b5e0a8c491

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# json_tokener.c:355:6: error: variable ‘size’ set but not used [-Werror=unused-but-set-variable]
	patch -p0 <<"EOF"
--- json_tokener.c.orig	2016-01-23 17:10:32.172313661 +0800
+++ json_tokener.c	2016-01-23 17:12:59.492358678 +0800
@@ -352,12 +352,10 @@ struct json_object* json_tokener_parse_e
 
     case json_tokener_state_inf: /* aka starts with 'i' */
       {
-	int size;
 	int size_inf;
 	int is_negative = 0;
 
 	printbuf_memappend_fast(tok->pb, &c, 1);
-	size = json_min(tok->st_pos+1, json_null_str_len);
 	size_inf = json_min(tok->st_pos+1, json_inf_str_len);
 	char *infbuf = tok->pb->buf;
 	if (*infbuf == '-')
EOF
}
