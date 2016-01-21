#!/bin/sh -e
#
# - See section "Growth of the feature set",
#   http://invisible-island.net/ncurses/ncurses.faq.html
#
PKG_NAME=ncurses
PKG_VERSION=5.9
PKG_SOURCE="ncurses-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/ncurses/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8cb9c412e5f2d96bc6f459aa8c6282a1

. "$PWD/env.sh"

PATCHDATE=20141206
PATCHBALL="ncurses-$PKG_VERSION-patch-$PATCHDATE.sh.gz"
PATCHURL="ftp://invisible-island.net/ncurses/$PKG_VERSION/patch-$PKG_VERSION-$PATCHDATE.sh.gz"

fetch_patches() {
	download_http "$PATCHBALL" "$PATCHURL" "170392a335809136d8fb6ba175ee1dba"
}

apply_patches() {
	local f

	cd "$PKG_BUILD_DIR"

	if [ -f ".patched" ]; then
		__errmsg "$PKG_BUILD_DIR/.patched exists, skip patching."
		return 0
	fi

	gunzip -c "$BASE_DL_DIR/$PATCHBALL" | sh -e
	touch .patched
}

do_patch() {
	cd "$PKG_BUILD_DIR"

	fetch_patches
	apply_patches
}

# We don't want to be affected by ncurses libraries of the build system
EXTRA_CPPFLAGS=
EXTRA_CFLAGS=
EXTRA_LDFLAGS="-L$INSTALL_PREFIX/lib -Wl,-rpath,$INSTALL_PREFIX/lib"
# - enable building shared libraries
# - suppress check for ada95
# - dont generate debug-libraries (those ending with _g)
# - compile with wide-char/UTF-8 code
# - --enable-overwrite,
# - compile in termcap fallback support
# - compile with SIGWINCH handler
CONFIGURE_ARGS="						\\
	--with-shared						\\
	--with-cxx-shared					\\
	--with-normal						\\
	--with-manpage-format=normal		\\
	--with-pkg-config-libdir='$INSTALL_PREFIX/lib/pkgconfig'	\\
	--without-ada						\\
	--without-debug						\\
	--enable-widec						\\
	--enable-overwrite					\\
	--enable-termcap					\\
	--enable-sigwinch					\\
	--enable-pc-files					\\
	--mandir=$INSTALL_PREFIX/share/man	\\
"
# we cannot do autoreconf because AC_DIVERT_HELP may not be universally
# available

staging_post() {
	local major="${PKG_VERSION%%.*}"
	local f based="$PKG_STAGING_DIR/$INSTALL_PREFIX"
	local suf sufm

	if os_is_linux; then
		suf=so
		sufm="so.${major}"
	else
		suf=dylib
		sufm="${major}.dylib"
	fi

	# link from normal version to the wchar version.  and the name ncurses++w
	# is just right, not the ncursesw++
	for f in form menu panel ncurses ncurses++; do
		ln -s "lib${f}w.$sufm" "$based/lib/lib${f}.$suf"
		ln -s "lib${f}w.$sufm" "$based/lib/lib${f}.$sufm"
		ln -s "lib${f}w.a" "$based/lib/lib${f}.a"
		ln -s "${f}w.pc" "$based/lib/pkgconfig/${f}.pc"
	done
	# link from curses version to ncurses with wchar support version
	for f in curses curses++; do
		# or we can make a lib${f}.$suf with content INPUT(libn${f}w.$suf)
		ln -s "libn${f}w.$suf" "$based/lib/lib${f}.$suf"
		ln -s "libn${f}w.a" "$based/lib/lib${f}.a"
		ln -s "n${f}w.pc" "$based/lib/pkgconfig/${f}.pc"
	done
	ln -s "libncurses.$sufm" $based/lib/libtermcap.$suf
	ln -s "ncursesw${major}-config" "$based/bin/ncurses${major}-config"
}
