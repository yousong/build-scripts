#!/bin/sh -e

PKG_NAME=gdb
PKG_VERSION=7.10.1
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/gdb/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=39e654460c9cdd80200a29ac020cfe11
PKG_DEPENDS='libiconv zlib ncurses xz'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	# use libiconv instead of the one from libc.  This is required because
	# 1. 'additional_includedir=${prefix}/include' from config/lib-prefix.m4
	#    was appended to CPPFLAGS when searching for liblzma
	# 2. we find iconv support from libc, so no need to add -liconv to LIBS
	# 3. but libiconv header will be included first when compiling gdb/charset.c
	# 4. iconv_open is a macro definition from libiconv header and the real one
	#    is libiconv_open
	# 5. then error would occur when linking gdb because iconv_open is a macro
	#    definition utilizing libiconv_open but the linker was not informed of
	#    this with -liconv
	#
	# We cannot do autoheader fixup because autoconf version of exact 2.64 is required
	patch -p0 <<"EOF"
--- gdb/acinclude.m4.orig	2016-02-02 16:46:54.344000087 +0800
+++ gdb/acinclude.m4	2016-02-02 16:46:57.778000087 +0800
@@ -221,16 +221,6 @@ AC_DEFUN([AM_ICONV],
       done
     fi
 
-    # Next, try to find iconv in libc.
-    if test "$am_cv_func_iconv" != yes; then
-      AC_TRY_LINK([#include <stdlib.h>
-#include <iconv.h>],
-        [iconv_t cd = iconv_open("","");
-         iconv(cd,NULL,NULL,NULL,NULL);
-         iconv_close(cd);],
-        am_cv_func_iconv=yes)
-    fi
-
     # If iconv was not in libc, try -liconv.  In this case, arrange to
     # look in the libiconv prefix, if it was specified by the user.
     if test "$am_cv_func_iconv" != yes; then
--- gdb/configure.orig	2016-02-02 17:58:35.974000093 +0800
+++ gdb/configure	2016-02-02 17:58:41.053000087 +0800
@@ -7170,29 +7170,6 @@ rm -f core conftest.err conftest.$ac_obj
       done
     fi
 
-    # Next, try to find iconv in libc.
-    if test "$am_cv_func_iconv" != yes; then
-      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdlib.h>
-#include <iconv.h>
-int
-main ()
-{
-iconv_t cd = iconv_open("","");
-         iconv(cd,NULL,NULL,NULL,NULL);
-         iconv_close(cd);
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
-  am_cv_func_iconv=yes
-fi
-rm -f core conftest.err conftest.$ac_objext \
-    conftest$ac_exeext conftest.$ac_ext
-    fi
-
     # If iconv was not in libc, try -liconv.  In this case, arrange to
     # look in the libiconv prefix, if it was specified by the user.
     if test "$am_cv_func_iconv" != yes; then
EOF
}

# it's possible that binutils was installed first with include/bfd.h having no
# definition of `struct bfd_build_id`, yet the bfd library bundled with gdb has
# it but the build system will still use the one installed by bintuils while
# compiling py-objfile.c of python binding support.
#
# Remove reference to custom -I$INSTALL_PREFIX
EXTRA_CFLAGS=
EXTRA_CPPFLAGS=

configure_pre() {
	# config.cache under readline/ directory was not removed by make distclean
	#
	# or use --cache-file=/dev/null
	find "$PKG_BUILD_DIR" -name 'config.cache' | xargs rm -vf
}

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--with-python					\\
"
