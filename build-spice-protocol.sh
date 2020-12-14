#!/bin/bash -e
#
# Copyright 2019-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# > headers defining protocols
#
PKG_NAME=spice-protocol
PKG_VERSION=0.14.3
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.spice-space.org/download/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=950e08044497ca9cf64e368cb3ceb395
PKG_MESON=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
GCC 4.8.5 on CentOS 7 does not support this use of __attribute__((deprecated))
on individual enumerator

--- a/spice/enums.h.orig	2020-12-14 14:05:08.337987803 +0800
+++ b/spice/enums.h	2020-12-14 14:05:12.970983491 +0800
@@ -377,7 +377,7 @@ typedef enum SpiceCursorFlags {
 typedef enum SpiceAudioDataMode {
     SPICE_AUDIO_DATA_MODE_INVALID,
     SPICE_AUDIO_DATA_MODE_RAW,
-    SPICE_AUDIO_DATA_MODE_CELT_0_5_1 SPICE_GNUC_DEPRECATED,
+    SPICE_AUDIO_DATA_MODE_CELT_0_5_1,
     SPICE_AUDIO_DATA_MODE_OPUS,
 
     SPICE_AUDIO_DATA_MODE_ENUM_END
EOF
}
