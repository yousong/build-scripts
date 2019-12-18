#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# @libevent for libevent_openssl lib
#
# - Features and requirements, https://nghttp2.org/documentation/package_README.html#requirements
#
# Compiler requirements
#
# > Compiling libnghttp2 C source code requires a C99 compiler. gcc 4.8 is known
# > to be adequate. In order to compile the C++ source code, gcc >= 6.0 or clang
# > >= 6.0 is required. C++ source code requires C++14 language features.
#
PKG_NAME=nghttp2
PKG_VERSION=1.40.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://github.com/nghttp2/nghttp2/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8d1a6b96760254e4dd142d7176e8fb7c
PKG_AUTOCONF_FIXUP=1
PKG_DEPENDS='libevent'

. "$PWD/env.sh"

#env_init_gnu_toolchain

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# The bundled ax_python_devel.m4 misses -lm ld option
	#
	# ax_python_devel, http://www.gnu.org/software/autoconf-archive/ax_python_devel.html
	patch -p0 <<"EOF"
--- m4/ax_python_devel.m4.orig	2015-12-23 13:52:36.385000016 +0800
+++ m4/ax_python_devel.m4	2015-12-23 13:52:49.644000016 +0800
@@ -279,7 +279,7 @@ AS_IF([test -z "$no_python_devel"], [
 	if test -z "$PYTHON_EXTRA_LIBS"; then
 	   PYTHON_EXTRA_LIBS=`$PYTHON -c "import distutils.sysconfig; \
                 conf = distutils.sysconfig.get_config_var; \
-                print (conf('LIBS'))"`
+                print (conf('LIBS') + ' ' + conf('SYSLIBS'))"`
 	fi
 	AC_MSG_RESULT([$PYTHON_EXTRA_LIBS])
 	AC_SUBST(PYTHON_EXTRA_LIBS)
--- python/Makefile.am.orig	2015-12-23 14:42:45.957000016 +0800
+++ python/Makefile.am	2015-12-23 14:43:12.781000016 +0800
@@ -33,7 +33,7 @@ all-local: nghttp2.c
 	$(PYTHON) setup.py build
 
 install-exec-local:
-	$(PYTHON) setup.py install --prefix=$(DESTDIR)$(prefix)
+	$(PYTHON) setup.py install --prefix=$(prefix) --root=$(DESTDIR)
 
 uninstall-local:
 	rm -f $(DESTDIR)$(libdir)/python*/site-packages/nghttp2.so
EOF

	# Including both event.h and event2/event.h will cause redefinition error.
	patch -p0 <<"EOF"
--- examples/libevent-client.c.orig	2016-06-11 18:59:02.552256366 +0800
+++ examples/libevent-client.c	2016-06-11 18:59:06.132256875 +0800
@@ -58,7 +58,6 @@ char *strndup(const char *s, size_t size
 #include <openssl/err.h>
 #include <openssl/conf.h>
 
-#include <event.h>
 #include <event2/event.h>
 #include <event2/bufferevent_ssl.h>
 #include <event2/dns.h>
--- examples/libevent-server.c.orig	2016-06-11 19:00:04.736274948 +0800
+++ examples/libevent-server.c	2016-06-11 19:00:09.164276603 +0800
@@ -66,7 +66,6 @@
 #include <openssl/err.h>
 #include <openssl/conf.h>
 
-#include <event.h>
 #include <event2/event.h>
 #include <event2/bufferevent_ssl.h>
 #include <event2/listener.h>
EOF
}

CONFIGURE_ARGS+=(
	--disable-silent-rules
)
