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
From 6c6a312474fb3954940a631a56ed045c84abfc9d Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Thu, 27 Jun 2019 08:27:18 +0000
Subject: [PATCH] column: fix outputing empty column at the end of line

The following commands manifests the problem.  In old versions before
commit 4762ae9d60 ("column: use libsmartcols for --table"), both of them
should output with 2 "|"

	echo '||'  | column -o '|' -s '|' -t
	echo '|| ' | column -o '|' -s '|' -t

Fixes: 4762ae9d60 ("column: use libsmartcols for --table")
Signed-off-by: Yousong Zhou <zhouyousong@yunionyun.com>
---
 tests/expected/column/table-empty-column-at-eol  |  1 +
 tests/expected/column/table-empty-column-at-eol2 |  1 +
 tests/ts/column/table                            |  8 ++++++++
 text-utils/column.c                              | 15 ++++++++++-----
 4 files changed, 20 insertions(+), 5 deletions(-)
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
index 13b39537e..64f1cf7e9 100644
--- a/text-utils/column.c
+++ b/text-utils/column.c
@@ -169,8 +169,9 @@ static wchar_t *local_wcstok(wchar_t *p, const wchar_t *separator, int greedy, w
 		return strtok_r(p, separator, state);
 #endif
 	if (!p) {
-		if (!*state || !**state)
+		if (!*state) {
 			return NULL;
+		}
 		p = *state;
 	}
 	result = p;
@@ -435,7 +436,7 @@ static int add_line_to_table(struct column_control *ctl, wchar_t *wcs)
 	if (!ctl->tab)
 		init_table(ctl);
 
-	while ((wcdata = local_wcstok(wcs, ctl->input_separator, ctl->greedy, &sv))) {
+	while ((wcdata = local_wcstok(wcs, ctl->input_separator, ctl->greedy, &sv)) || sv) {
 		char *data;
 
 		if (scols_table_get_ncols(ctl->tab) < n + 1) {
@@ -452,9 +453,13 @@ static int add_line_to_table(struct column_control *ctl, wchar_t *wcs)
 				err(EXIT_FAILURE, _("failed to allocate output line"));
 		}
 
-		data = wcs_to_mbs(wcdata);
-		if (!data)
-			err(EXIT_FAILURE, _("failed to allocate output data"));
+		if (wcdata) {
+			data = wcs_to_mbs(wcdata);
+			if (!data)
+				err(EXIT_FAILURE, _("failed to allocate output data"));
+		} else {
+			data = NULL;
+		}
 		if (scols_line_refer_data(ln, n, data))
 			err(EXIT_FAILURE, _("failed to add output data"));
 		n++;
EOF
}

CONFIGURE_ARGS+=(
	--disable-makeinstall-chown
	--disable-makeinstall-setuid
)
