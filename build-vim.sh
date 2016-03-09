#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Vim on Debian Wheezy 7 has version 7.3.547 (Fetched with command "vim --version")
#
#	sudo apt-get build-dep vim-nox
#	sudo apt-get install gawk liblua5.2-dev libncurses5-dev
#
# Vim on CentOS 7 has version 7.4.160
#
#	sudo yum-builddep vim-enhanced
#	# or use the following method if you are on CentOS 6.5
#	sudo yum install -y lua-devel ruby-devel python-devel ncurses-devel perl-devel perl-ExtUtils-Embed
#
# 7.3 is the release version.
# 547 is the number of applied patches provided by vim.org.
PKG_NAME=vim
PKG_VERSION=7.4
PKG_SOURCE="vim-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="ftp://ftp.vim.org/pub/vim/unix/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=607e135c559be642f210094ad023dc65
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libiconv LuaJIT ncurses python2'

. "$PWD/env.sh"
VER_ND="$(echo $PKG_VERSION | tr -d .)"
PATCH_DIR="$BASE_DL_DIR/vim$VER_ND-patches"

patches_all_fetched() {
	if [ -s "MD5SUMS" ] && md5sum --status -c MD5SUMS; then
		return 0
	else
		return 1
	fi
}

fetch_patches() {
	local ver="$PKG_VERSION"
	local baseurl="ftp://ftp.vim.org/pub/vim/patches/$PKG_VERSION"
	local num_patches
	local num_process
	local i l

	mkdir -p "$PATCH_DIR"
	cd "$PATCH_DIR"

	if patches_all_fetched; then
		__errmsg "All fetched, skip fetching patches"
		return 0
	fi

	# delete MD5SUMS to check for new patches
	wget -c "$baseurl/MD5SUMS"
	num_patches="$(wc -l MD5SUMS | cut -f1 -d' ')"
	num_process="$(($num_patches / 100))"
	for i in $(seq 0 $num_process); do
		# Each wget fetches at most 100 patches.
		grep "$PKG_VERSION\\.$i[0-9]\\+$" MD5SUMS | \
			while read l; do echo "$l" | md5sum --status -c || echo "$baseurl/${l##* }"; done | \
			wget --no-verbose -c -i - &
	done
	wait

	if ! patches_all_fetched; then
		__errmsg "Some patches were missing"
		return 1
	fi
}

apply_patches() {
	local f

	cd "$PKG_BUILD_DIR"

	if [ -f ".patched" ]; then
		__errmsg "$PKG_BUILD_DIR/.patched exists, skip patching."
		return 0
	fi

	for f in $(ls "$PATCH_DIR/$PKG_VERSION."*); do
		__errmsg "applying patch $f"
		patch -p0 -i "$f"
		__errmsg
	done
	touch .patched
}

do_patch() {
	fetch_patches
	apply_patches

	# our python was not configured with --enable-framework=xxx
	patch -p0 <<"EOF"
--- src/configure.in.orig	2015-05-29 22:32:15.000000000 +0200
+++ src/configure.in	2015-05-29 22:34:23.000000000 +0200
@@ -1133,13 +1137,6 @@
 	    dnl -- delete the lines from make about Entering/Leaving directory
 	    eval "`cd ${PYTHON_CONFDIR} && make -f "${tmp_mkf}" __ | sed '/ directory /d'`"
 	    rm -f -- "${tmp_mkf}"
-	    if test "x$MACOSX" = "xyes" && ${vi_cv_path_python} -c \
-		"import sys; sys.exit(${vi_cv_var_python_version} < 2.3)"; then
-	      vi_cv_path_python_plibs="-framework Python"
-	      if test "x${vi_cv_path_python}" != "x/usr/bin/python" && test -n "${python_PYTHONFRAMEWORKPREFIX}"; then
-		  vi_cv_path_python_plibs="-F${python_PYTHONFRAMEWORKPREFIX} -framework Python"
-	      fi
-	    else
 	      if test "${vi_cv_var_python_version}" = "1.4"; then
 		  vi_cv_path_python_plibs="${PYTHON_CONFDIR}/libModules.a ${PYTHON_CONFDIR}/libPython.a ${PYTHON_CONFDIR}/libObjects.a ${PYTHON_CONFDIR}/libParser.a"
 	      else
@@ -1167,7 +1164,6 @@
 	      vi_cv_path_python_plibs="${vi_cv_path_python_plibs} ${python_BASEMODLIBS} ${python_LIBS} ${python_SYSLIBS} ${python_LINKFORSHARED}"
 	      dnl remove -ltermcap, it can conflict with an earlier -lncurses
 	      vi_cv_path_python_plibs=`echo $vi_cv_path_python_plibs | sed s/-ltermcap//`
-	    fi
 	])
 	AC_CACHE_VAL(vi_cv_dll_name_python,
 	[
EOF

	# Include those from INSTALL_PREFIX first
	patch -p0 <<"EOF"
--- src/Makefile.orig	2016-01-31 22:54:08.000000000 +0800
+++ src/Makefile	2016-01-31 22:56:43.000000000 +0800
@@ -2670,33 +2670,33 @@ objects/if_xcmdsrv.o: if_xcmdsrv.c
 	$(CCC) -o $@ if_xcmdsrv.c
 
 objects/if_lua.o: if_lua.c
-	$(CCC) $(LUA_CFLAGS) -o $@ if_lua.c
+	$(CC) -c -I$(srcdir) $(LUA_CFLAGS) $(ALL_CFLAGS) -o $@ if_lua.c
 
 objects/if_mzsch.o: if_mzsch.c $(MZSCHEME_EXTRA)
-	$(CCC) -o $@ $(MZSCHEME_CFLAGS_EXTRA) if_mzsch.c
+	$(CC) -c -I$(srcdir) -o $@ $(MZSCHEME_CFLAGS_EXTRA) $(ALL_CFLAGS) if_mzsch.c
  
 mzscheme_base.c:
 	$(MZSCHEME_MZC) --c-mods mzscheme_base.c ++lib scheme/base
 
 objects/if_perl.o: auto/if_perl.c
-	$(CCC) $(PERL_CFLAGS) -o $@ auto/if_perl.c
+	$(CC) -c -I$(srcdir) $(PERL_CFLAGS) $(ALL_CFLAGS) -o $@ auto/if_perl.c
 
 objects/if_perlsfio.o: if_perlsfio.c
-	$(CCC) $(PERL_CFLAGS) -o $@ if_perlsfio.c
+	$(CC) -c -I$(srcdir) $(PERL_CFLAGS) $(ALL_CFLAGS) -o $@ if_perlsfio.c
 
 objects/py_getpath.o: $(PYTHON_CONFDIR)/getpath.c
-	$(CCC) $(PYTHON_CFLAGS) -o $@ $(PYTHON_CONFDIR)/getpath.c \
+	$(CC) -c -I$(srcdir) $(PYTHON_CFLAGS) -o $@ $(PYTHON_CONFDIR)/getpath.c \
 		-I$(PYTHON_CONFDIR) -DHAVE_CONFIG_H -DNO_MAIN \
-		$(PYTHON_GETPATH_CFLAGS)
+		$(PYTHON_GETPATH_CFLAGS) $(ALL_CFLAGS)
 
 objects/if_python.o: if_python.c if_py_both.h
-	$(CCC) $(PYTHON_CFLAGS) $(PYTHON_CFLAGS_EXTRA) -o $@ if_python.c
+	$(CC) -c -I$(srcdir) $(PYTHON_CFLAGS) $(PYTHON_CFLAGS_EXTRA) $(ALL_CFLAGS) -o $@ if_python.c
 
 objects/if_python3.o: if_python3.c if_py_both.h
-	$(CCC) $(PYTHON3_CFLAGS) $(PYTHON3_CFLAGS_EXTRA) -o $@ if_python3.c
+	$(CC) -c -I$(srcdir) $(PYTHON3_CFLAGS) $(PYTHON3_CFLAGS_EXTRA) $(ALL_CFLAGS) -o $@ if_python3.c
 
 objects/if_ruby.o: if_ruby.c
-	$(CCC) $(RUBY_CFLAGS) -o $@ if_ruby.c
+	$(CC) -c -I$(srcdir) $(RUBY_CFLAGS) $(ALL_CFLAGS) -o $@ if_ruby.c
 
 objects/if_sniff.o: if_sniff.c
 	$(CCC) -o $@ if_sniff.c
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--enable-fail-if-missing	\\
	--enable-luainterp			\\
	--enable-perlinterp			\\
	--enable-pythoninterp		\\
	--enable-rubyinterp			\\
	--enable-cscope				\\
	--enable-multibyte			\\
	--disable-gui				\\
	--disable-gtktest			\\
	--disable-xim				\\
	--without-x					\\
	--disable-netbeans			\\
	--with-luajit				\\
	--with-lua-prefix='$INSTALL_PREFIX'	\\
	--with-tlib=ncurses			\\
	--with-features=big			\\
"

configure_pre() {
	cd "$PKG_SOURCE_DIR/src"
	$MAKEJ autoconf
}
