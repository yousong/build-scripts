#!/bin/sh -e
#
# @cython for building python binding
# @libevent for libevent_openssl lib
#
# - Features and requirements, https://nghttp2.org/documentation/package_README.html#requirements
#
PKG_NAME=nghttp2
PKG_VERSION=1.5.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://github.com/tatsuhiro-t/nghttp2/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=390f2cc0a4898069d5933ba8163365f2
PKG_AUTOCONF_FIXUP=1
PKG_DEPENDS='Cython libevent'

. "$PWD/env.sh"

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
}

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--disable-silent-rules		\\
"
