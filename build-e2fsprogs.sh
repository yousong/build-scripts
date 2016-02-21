#!/bin/sh -e
#
PKG_NAME=e2fsprogs
PKG_VERSION=1.42.13
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ce8e4821f5f53d4ebff4195038e38673

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# install-libs for installing static libraries and .pc files
	patch -p0 <<"EOF"
--- Makefile.in
+++ Makefile.in
@@ -62,7 +62,7 @@
 
 install: subs all-libs-recursive install-progs-recursive \
   install-shlibs-libs-recursive install-doc-libs
-	if test ! -d e2fsck && test ! -d debugfs && test ! -d misc && test ! -d ext2ed ; then $(MAKE) install-libs ; fi
+	$(MAKE) install-libs
 
 install-strip: subs all-libs-recursive install-strip-progs-recursive \
   install-shlibs-strip-libs-recursive install-doc-libs
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-elf-shlibs				\\
"
MAKE_VARS='V=s'
