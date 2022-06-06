#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libfuse3
PKG_VERSION=3.11.0
PKG_SOURCE="fuse-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://github.com/libfuse/libfuse/releases/download/fuse-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=c9987e2c366655e2d3d9e1f7aaba3c0d
PKG_MESON=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- util/meson.build.orig	2022-06-06 12:42:19.330977451 +0000
+++ util/meson.build	2022-06-06 12:43:57.668561625 +0000
@@ -23,7 +23,7 @@ endif
 meson.add_install_script('install_helper.sh',
                          join_paths(get_option('prefix'), get_option('sysconfdir')),
                          join_paths(get_option('prefix'), get_option('bindir')),
-                         udevrulesdir,
+                         join_paths(get_option('prefix'), udevrulesdir.substring(1)),
                          '@0@'.format(get_option('useroot')))
 
 
--- util/install_helper.sh.orig	2022-06-06 12:43:19.594948524 +0000
+++ util/install_helper.sh	2022-06-06 12:43:41.398299624 +0000
@@ -40,7 +40,7 @@ install -D -m 644 "${MESON_SOURCE_ROOT}/
         "${DESTDIR}${udevrulesdir}/99-fuse3.rules"
 
 install -D -m 755 "${MESON_SOURCE_ROOT}/util/init_script" \
-        "${DESTDIR}/etc/init.d/fuse3"
+        "${DESTDIR}${sysconfdir}/init.d/fuse3"
 
 
 if test -x /usr/sbin/update-rc.d && test -z "${DESTDIR}"; then
EOF
}

MESON_ARGS+=(
	-Duseroot=false
)
