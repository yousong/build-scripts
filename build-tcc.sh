#!/bin/sh -e
#
# The plan is to firstly add MIPS32r2 support
#
# Refs
#
# - Tiny C Compiler, http://bellard.org/tcc/
# - Tiny C Compiler Savannah project page, http://savannah.gnu.org/projects/tinycc
#
PKG_NAME=tcc
PKG_VERSION=0.9.26
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/tinycc/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5fb28e4abc830c46a7f54c1f637fb25d

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch -p1 <<"EOF"
From ac93dabe74c513ea78549ad14e04320df53f752c Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Thu, 24 Dec 2015 11:25:44 +0800
Subject: [PATCH] configure: avoid ln the same file

The fix is for a clean configure exit status
---
 configure | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index 6a796f3..4cf73b7 100755
--- a/configure
+++ b/configure
@@ -585,6 +585,10 @@ rm -f $TMPN* $CONFTEST
 # ---------------------------------------------------------------------------
 # build tree in object directory if source path is different from current one
 
+fn_inode() {
+    stat -c %i "$1" 2>/dev/null
+}
+
 fn_makelink()
 {
     tgt=$1/$2
@@ -600,7 +604,9 @@ fn_makelink()
          esac
          ;;
     esac
-    ln -sfn $tgt $2
+    if [ "$(fn_inode "$tgt")" != "$(fn_inode "$2")" ]; then
+        ln -sfn $tgt $2
+    fi
 }
 
 if test "$source_path_used" = "yes" ; then
-- 
2.6.3
EOF
}

CONFIGURE_ARGS='		\
	--enable-cross		\
'
