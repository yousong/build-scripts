#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# It provides libblkid.so and libuuid.so
#
PKG_NAME=util-linux
PKG_VERSION=2.34
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/utils/util-linux/v2.34/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a78cbeaed9c39094b96a48ba8f891d50
PKG_DEPENDS=''
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
From a0491d2a8a4efbee8dec92f95245e8c349682ba3 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Thu, 27 Jun 2019 08:27:18 +0000
Subject: [PATCH v2] column: fix outputing empty column at the end of line

The following commands manifests the problem.  In old versions before
commit 4762ae9d60 ("column: use libsmartcols for --table"), both of them
should output with 2 "|"

	echo '||'  | column -o '|' -s '|' -t
	echo '|| ' | column -o '|' -s '|' -t

Fixes: 4762ae9d60 ("column: use libsmartcols for --table")
Signed-off-by: Yousong Zhou <zhouyousong@yunionyun.com>
Reviewed-by: Sami Kerola <kerolasa@iki.fi>
---
v2 <- v1 Simplify the patch as suggested by @kerolaso.  It seems that
only local_wcstok() needs to be changed.

 tests/expected/column/table-empty-column-at-eol  | 1 +
 tests/expected/column/table-empty-column-at-eol2 | 1 +
 tests/ts/column/table                            | 8 ++++++++
 text-utils/column.c                              | 2 +-
 4 files changed, 11 insertions(+), 1 deletion(-)
 create mode 100644 tests/expected/column/table-empty-column-at-eol
 create mode 100644 tests/expected/column/table-empty-column-at-eol2

diff --git a/tests/expected/column/table-empty-column-at-eol b/tests/expected/column/table-empty-column-at-eol
new file mode 100644
index 000000000..948cf947f
--- /dev/null
+++ b/tests/expected/column/table-empty-column-at-eol
@@ -0,0 +1 @@
+|
diff --git a/tests/expected/column/table-empty-column-at-eol2 b/tests/expected/column/table-empty-column-at-eol2
new file mode 100644
index 000000000..7c4378506
--- /dev/null
+++ b/tests/expected/column/table-empty-column-at-eol2
@@ -0,0 +1 @@
+||
diff --git a/tests/ts/column/table b/tests/ts/column/table
index bd1f16f3f..e64dee746 100755
--- a/tests/ts/column/table
+++ b/tests/ts/column/table
@@ -116,4 +116,12 @@ ts_init_subtest "empty-column"
 printf ':a:b\n' | $TS_CMD_COLUMN --table --separator ':' --output-separator  ':' >> $TS_OUTPUT 2>&1
 ts_finalize_subtest
 
+ts_init_subtest "empty-column-at-eol"
+printf '|' | $TS_CMD_COLUMN --separator '|' --output-separator '|' --table >> $TS_OUTPUT 2>&1
+ts_finalize_subtest
+
+ts_init_subtest "empty-column-at-eol2"
+printf '||' | $TS_CMD_COLUMN --separator '|' --output-separator '|' --table >> $TS_OUTPUT 2>&1
+ts_finalize_subtest
+
 ts_finalize
diff --git a/text-utils/column.c b/text-utils/column.c
index 13b39537e..9d56e514c 100644
--- a/text-utils/column.c
+++ b/text-utils/column.c
@@ -169,7 +169,7 @@ static wchar_t *local_wcstok(wchar_t *p, const wchar_t *separator, int greedy, w
 		return strtok_r(p, separator, state);
 #endif
 	if (!p) {
-		if (!*state || !**state)
+		if (!*state)
 			return NULL;
 		p = *state;
 	}
EOF
}

CONFIGURE_ARGS+=(
	--disable-makeinstall-chown
	--disable-makeinstall-setuid
)
