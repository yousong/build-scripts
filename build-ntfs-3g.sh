#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ntfs-3g
PKG_VERSION=2017.3.23
PKG_SOURCE="${PKG_NAME}_ntfsprogs-$PKG_VERSION.tgz"
PKG_SOURCE_URL="https://tuxera.com/opensource/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d97474ae1954f772c6d2fa386a6f462c
PKG_DEPENDS='libgcrypt libgnutls'
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
From 28e14357840b8462a9826acd3ef1c2c85f9be31e Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Fri, 25 Oct 2019 06:48:27 +0000
Subject: [PATCH 1/4] src: no run ldconfig

---
 src/Makefile.am | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/src/Makefile.am b/src/Makefile.am
index 8d98408..f495340 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -57,9 +57,6 @@ ntfs_3g_probe_SOURCES 	= ntfs-3g.probe.c
 drivers : $(FUSE_LIBS) ntfs-3g lowntfs-3g
 
 install-exec-hook:
-if RUN_LDCONFIG
-	$(LDCONFIG)
-endif
 if !DISABLE_PLUGINS
 	$(MKDIR_P) $(DESTDIR)/$(plugindir)
 endif

From 5e7955fd73edb9f5bb7731b346c0785d237575fc Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Fri, 25 Oct 2019 06:47:34 +0000
Subject: [PATCH 2/4] src: no rootbin, rootsbin

---
 src/Makefile.am | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/src/Makefile.am b/src/Makefile.am
index f495340..d815c32 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -19,8 +19,7 @@ endif
 if ENABLE_NTFS_3G
 
 bin_PROGRAMS	 = ntfs-3g.probe
-rootbin_PROGRAMS = ntfs-3g lowntfs-3g
-rootsbin_DATA 	 = #Create directory
+bin_PROGRAMS    += ntfs-3g lowntfs-3g
 man_MANS	 = ntfs-3g.8 ntfs-3g.probe.8
 
 ntfs_3g_LDADD    = $(LIBDL) $(FUSE_LIBS) $(top_builddir)/libntfs-3g/libntfs-3g.la
@@ -62,10 +61,10 @@ if !DISABLE_PLUGINS
 endif
 
 if ENABLE_MOUNT_HELPER
-install-exec-local:	install-rootbinPROGRAMS
-	$(MKDIR_P) "$(DESTDIR)/sbin"
-	$(LN_S) -f "$(rootbindir)/ntfs-3g" "$(DESTDIR)/sbin/mount.ntfs-3g"
-	$(LN_S) -f "$(rootbindir)/lowntfs-3g" "$(DESTDIR)/sbin/mount.lowntfs-3g"
+install-exec-local:
+	$(MKDIR_P) "$(DESTDIR)$(sbindir)"
+	$(LN_S) -f "ntfs-3g" "$(DESTDIR)$(sbindir)/mount.ntfs-3g"
+	$(LN_S) -f "lowntfs-3g" "$(DESTDIR)$(sbindir)/mount.lowntfs-3g"
 
 install-data-local:	install-man8
 	$(LN_S) -f ntfs-3g.8 "$(DESTDIR)$(man8dir)/mount.ntfs-3g.8"
@@ -73,7 +72,8 @@ install-data-local:	install-man8
 
 uninstall-local:
 	$(RM) -f "$(DESTDIR)$(man8dir)/mount.ntfs-3g.8"
-	$(RM) -f "$(DESTDIR)/sbin/mount.ntfs-3g" "$(DESTDIR)/sbin/mount.lowntfs-3g"
+	$(RM) -f "$(DESTDIR)$(man8dir)/mount.lowntfs-3g.8"
+	$(RM) -f "$(DESTDIR)$(sbindir)/mount.ntfs-3g" "$(DESTDIR)$(sbindir)/mount.lowntfs-3g"
 endif
 
 endif # ENABLE_NTFS_3G

From 5e33eb76885f132210d7e7954a736d90c3ec4be7 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Fri, 25 Oct 2019 06:50:56 +0000
Subject: [PATCH 3/4] libntfs-3g: dont move to rootlibdir

---
 libntfs-3g/Makefile.am | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/libntfs-3g/Makefile.am b/libntfs-3g/Makefile.am
index d6b150e..7a5a997 100644
--- a/libntfs-3g/Makefile.am
+++ b/libntfs-3g/Makefile.am
@@ -2,7 +2,6 @@
 MAINTAINERCLEANFILES = $(srcdir)/Makefile.in
 
 if INSTALL_LIBRARY
-rootlib_LTLIBRARIES=#Create directory
 lib_LTLIBRARIES    = libntfs-3g.la
 pkgconfig_DATA     = libntfs-3g.pc
 else
@@ -55,29 +54,6 @@ libntfs_3g_la_SOURCES += unix_io.c
 endif
 endif
 
-# We may need to move .so files to root
-# And create ldscript or symbolic link from /usr
-install-exec-hook: install-rootlibLTLIBRARIES
-if INSTALL_LIBRARY
-	if [ ! "$(rootlibdir)" -ef "$(libdir)" ]; then \
-		$(MV) -f "$(DESTDIR)/$(libdir)"/libntfs-3g.so* "$(DESTDIR)/$(rootlibdir)";  \
-	fi
-if GENERATE_LDSCRIPT
-	if [ ! "$(rootlibdir)" -ef "$(libdir)" ]; then \
-		$(install_sh_PROGRAM) "libntfs-3g.script.so" "$(DESTDIR)/$(libdir)/libntfs-3g.so"; \
-	fi
-else
-	if [ ! "$(rootlibdir)" -ef "$(libdir)" ]; then \
-		$(LN_S) "$(rootlibdir)/libntfs-3g.so" "$(DESTDIR)/$(libdir)/libntfs-3g.so"; \
-	fi
-endif
-endif
-
-uninstall-local:
-if INSTALL_LIBRARY
-	$(RM) -f "$(DESTDIR)/$(rootlibdir)"/libntfs-3g.so*
-endif
-
 if ENABLE_NTFSPROGS
 libs:	$(lib_LTLIBRARIES)
 endif

From b674aef52a9b201a5b87261e9f4a5b0663456a5d Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Fri, 25 Oct 2019 06:51:49 +0000
Subject: [PATCH 4/4] ntfsprogs: fix install-exec-hook

---
 ntfsprogs/Makefile.am | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ntfsprogs/Makefile.am b/ntfsprogs/Makefile.am
index f4f9d1b..71ab838 100644
--- a/ntfsprogs/Makefile.am
+++ b/ntfsprogs/Makefile.am
@@ -165,15 +165,15 @@ extras:	libs $(EXTRA_PROGRAMS)
 
 if ENABLE_MOUNT_HELPER
 install-exec-hook:
-	$(INSTALL) -d $(DESTDIR)/sbin
-	$(LN_S) -f $(sbindir)/mkntfs $(DESTDIR)/sbin/mkfs.ntfs
+	$(INSTALL) -d $(DESTDIR)$(sbindir)
+	$(LN_S) -f mkntfs $(DESTDIR)$(sbindir)/mkfs.ntfs
 
 install-data-hook:
 	$(INSTALL) -d $(DESTDIR)$(man8dir)
 	$(LN_S) -f mkntfs.8 $(DESTDIR)$(man8dir)/mkfs.ntfs.8
 
 uninstall-local:
-	$(RM) -f $(DESTDIR)/sbin/mkfs.ntfs
+	$(RM) -f $(DESTDIR)$(sbindir)/mkfs.ntfs
 	$(RM) -f $(DESTDIR)$(man8dir)/mkfs.ntfs.8
 endif
 
EOF
}

CONFIGURE_ARGS+=(
	--enable-crypto
)
