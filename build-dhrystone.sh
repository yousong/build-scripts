#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Run it with ./doit in the build dir and the result will be available in the
# file "results"
#
# To compute DMIPS/MHz
#
#	Dhrystones_per_Second / 1757 / cpu_MHz
#
# where
#
#  - Dhrystones_per_Second is the benchmark result
#  - 1757 is the DMIPS/MHz of machine VAX 11/780
#  - cpu_MHz can be got from /proc/cpuinfo
#
PKG_NAME=dhrystone
PKG_VERSION=2.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://fossies.org/linux/privat/old/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=15e13d1d2329571a60c04b2f05920d24
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

prepare_source() {
	local dir
	local trans_exp

	dir="$(basename $PKG_SOURCE_DIR)"
	trans_exp="s:^:$dir/:"
	untar "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR" "$trans_exp"
}

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- dhry_1.c.orig	2017-02-08 14:08:30.968355887 +0800
+++ dhry_1.c	2017-02-08 14:08:39.348358508 +0800
@@ -45,7 +45,7 @@ Enumeration     Func_1 ();
 
 #ifdef TIMES
 struct tms      time_info;
-extern  int     times ();
+extern clock_t  times ();
                 /* see library function "times" */
 #define Too_Small_Time (2*HZ)
                 /* Measurements should last at least about 2 seconds */
EOF

	patch -p0 <<"EOF"
--- doit.orig	2017-02-08 14:21:15.352595129 +0800
+++ doit	2017-02-08 14:21:37.860602174 +0800
@@ -1,22 +1,22 @@
 #!/bin/sh
-PASSES=1000000
+PASSES=200000000
 
 echo "cc without register ($PASSES passes)" > results
-cc_dry2 <<MIC | egrep '^Microseconds|^Dhrystones' >>results
+./cc_dry2 <<MIC | egrep '^Microseconds|^Dhrystones' >>results
 $PASSES
 MIC
 echo "" >>results
 echo "cc with register ($PASSES passes)" >>results
-cc_dry2reg <<MIC | egrep '^Microseconds|^Dhrystones' >>results
+./cc_dry2reg <<MIC | egrep '^Microseconds|^Dhrystones' >>results
 $PASSES
 MIC
 echo "" >>results
 echo "gcc without register ($PASSES passes)" >>results
-gcc_dry2 <<MIC | egrep '^Microseconds|^Dhrystones' >>results
+./gcc_dry2 <<MIC | egrep '^Microseconds|^Dhrystones' >>results
 $PASSES
 MIC
 echo "" >>results
 echo "gcc with register ($PASSES passes)" >>results
-gcc_dry2reg <<MIC | egrep '^Microseconds|^Dhrystones' >>results
+./gcc_dry2reg <<MIC | egrep '^Microseconds|^Dhrystones' >>results
 $PASSES
 MIC
EOF
}

configure() {
	true
}

staging() {
	true
}

install() {
	true
}

