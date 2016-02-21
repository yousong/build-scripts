#!/bin/sh -e
#
PKG_NAME=readline
PKG_VERSION=6.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://ftp.cwru.edu/pub/bash/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=33c8fb279e981274f485fd91da77e94a
PKG_DEPENDS=ncurses

. "$PWD/env.sh"

VER_ND="$(echo $PKG_VERSION | tr -d .)"
PATCH_DIR="$BASE_DL_DIR/readline$VER_ND-patches"

patches_md5sum() {
	cat <<EOF
4343f5ea9b0f42447f102fb61576b398  readline63-001
700295212f7e2978577feaee584afddb  readline63-002
af4963862f5156fbf9111c2c6fa86ed7  readline63-003
11f9def89803a5052db3ba72394ce14f  readline63-004
93721c31cd225393f80cb3aadb165544  readline63-005
71dc6ecce66d1489b96595f55d142a52  readline63-006
062a08ed60679d3c4878710b3d595b65  readline63-007
ee1c04072154826870848d8b218d7b04  readline63-008
EOF
}

patches_all_fetched() {
	patches_md5sum | md5sum --status -c
}

fetch_patches() {
	local ver="$PKG_VERSION"
	local baseurl="ftp://ftp.cwru.edu/pub/bash/readline-$PKG_VERSION-patches"
	local l

	mkdir -p "$PATCH_DIR"
	cd "$PATCH_DIR"

	if patches_all_fetched; then
		__errmsg "All fetched, skip fetching patches"
		return 0
	fi

	patches_md5sum | \
		while read l; do echo "$l" | md5sum --status -c || echo "$baseurl/${l##* }"; done | \
		wget --no-verbose -c -i -

	if ! patches_all_fetched; then
		__errmsg "Some patches were missing"
		return 1
	fi
}

apply_patches() {
	local f

	cd "$PKG_SOURCE_DIR"

	if [ -f ".patched" ]; then
		__errmsg "$PKG_SOURCE_DIR/.patched exists, skip patching."
		return 0
	fi

	for f in $(ls "$PATCH_DIR/readline$VER_ND"*); do
		__errmsg "applying patch $f"
		patch -p0 -i "$f"
		__errmsg
	done
	touch .patched
}

do_patch() {
	cd "$PKG_SOURCE_DIR"

	fetch_patches
	apply_patches

	# use $(TERMCAP_LIB) for libreadline.so and libhistory.so on linux
	patch -p0 <<"EOF"
--- support/shobj-conf.orig	2016-01-12 12:12:04.921243295 +0800
+++ support/shobj-conf	2016-01-12 12:12:06.881244152 +0800
@@ -130,6 +130,7 @@ linux*-*|gnu*-*|k*bsd*-gnu-*|freebsd*-ge
 
 	SHLIB_XLDFLAGS='-Wl,-rpath,$(libdir) -Wl,-soname,`basename $@ $(SHLIB_MINOR)`'
 	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
+	SHLIB_LIBS='$(TERMCAP_LIB)'
 	;;
 
 freebsd2*)
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-shared					\\
	--enable-multibyte				\\
	--with-curses					\\
"
