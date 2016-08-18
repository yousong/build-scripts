#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Show build configuration
#
#	ffmpeg -buildconf
#
# OpenH264 is not enabled because version 1.6.0 of it does not work with 3.1.2
# at the moment.
#
# - Compilation Guide, https://trac.ffmpeg.org/wiki/CompilationGuide
#
PKG_NAME=ffmpeg
PKG_VERSION=3.1.2
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://ffmpeg.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8095acdc8d5428b2a9861cb82187ea73
PKG_DEPENDS='libass bzip2 fdk-aac fribidi gnutls openjpeg rtmpdump x264 x265 xvidcore yasm zlib'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	# taken from https://trac.ffmpeg.org/ticket/5694
	patch -p1 <<"EOF"
diff -rupN ffmpeg-3.1.1/configure ffmpeg-3.1.1-new/configure
--- ffmpeg-3.1.1/configure	2016-06-27 01:54:28.000000000 +0200
+++ ffmpeg-3.1.1-new/configure	2016-07-27 22:25:36.585141648 +0200
@@ -5669,7 +5669,7 @@ enabled libopencv         && { check_hea
                                  require opencv opencv2/core/core_c.h cvCreateImageHeader -lopencv_core -lopencv_imgproc; } ||
                                require_pkg_config opencv opencv/cxcore.h cvCreateImageHeader; }
 enabled libopenh264       && require_pkg_config openh264 wels/codec_api.h WelsGetCodecVersion
-enabled libopenjpeg       && { check_lib openjpeg-2.1/openjpeg.h opj_version -lopenjp2 -DOPJ_STATIC ||
+enabled libopenjpeg       && { check_lib openjpeg-2.1/openjpeg.h opj_version -lopenjp2 ||
                                check_lib openjpeg-2.0/openjpeg.h opj_version -lopenjp2 -DOPJ_STATIC ||
                                check_lib openjpeg-1.5/openjpeg.h opj_version -lopenjpeg -DOPJ_STATIC ||
                                check_lib openjpeg.h opj_version -lopenjpeg -DOPJ_STATIC ||
diff -rupN ffmpeg-3.1.1/libavcodec/libopenjpegdec.c ffmpeg-3.1.1-new/libavcodec/libopenjpegdec.c
--- ffmpeg-3.1.1/libavcodec/libopenjpegdec.c	2016-06-27 01:54:29.000000000 +0200
+++ ffmpeg-3.1.1-new/libavcodec/libopenjpegdec.c	2016-07-27 22:25:45.509327071 +0200
@@ -24,8 +24,6 @@
  * JPEG 2000 decoder using libopenjpeg
  */

-#define  OPJ_STATIC
-
 #include "libavutil/common.h"
 #include "libavutil/imgutils.h"
 #include "libavutil/intreadwrite.h"
diff -rupN ffmpeg-3.1.1/libavcodec/libopenjpegenc.c ffmpeg-3.1.1-new/libavcodec/libopenjpegenc.c
--- ffmpeg-3.1.1/libavcodec/libopenjpegenc.c	2016-06-27 01:54:29.000000000 +0200
+++ ffmpeg-3.1.1-new/libavcodec/libopenjpegenc.c	2016-07-27 22:25:40.298218807 +0200
@@ -24,8 +24,6 @@
  * JPEG 2000 encoder using libopenjpeg
  */

-#define  OPJ_STATIC
-
 #include "libavutil/avassert.h"
 #include "libavutil/common.h"
 #include "libavutil/imgutils.h"
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-shared					\\
	--enable-gpl					\\
	--enable-version3				\\
	--enable-nonfree				\\
	--enable-gnutls					\\
	--enable-libfdk-aac				\\
	--enable-libx264				\\
	--enable-libx265				\\
	--enable-libmp3lame				\\
	--enable-libass					\\
	--enable-libfribidi				\\
	--enable-librtmp				\\
	--enable-libopenjpeg			\\
	--enable-libfreetype			\\
	--enable-libcaca				\\
	--enable-libxvid				\\
"
