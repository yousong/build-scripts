#!/bin/sh -e
#
PKG_NAME=ncurses5
PKG_VERSION=5.9
PKG_SOURCE="ncurses-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/ncurses/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8cb9c412e5f2d96bc6f459aa8c6282a1

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/ncurses-$PKG_VERSION"
PKG_STAGING_DIR="$BASE_DESTDIR/ncurses-$PKG_VERSION-install"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch -p0 <<"EOF"
--- c++/cursesf.h.orig	2011-07-23 10:05:34.000000000 +0200
+++ c++/cursesf.h	2011-07-23 10:06:20.000000000 +0200
@@ -677,7 +677,7 @@
   }
 
 public:
-  NCursesUserForm (NCursesFormField Fields[],
+  NCursesUserForm (NCursesFormField* Fields[],
 		   const T* p_UserData = STATIC_CAST(T*)(0),
 		   bool with_frame=FALSE,
 		   bool autoDelete_Fields=FALSE)
@@ -686,7 +686,7 @@
 	set_user (const_cast<void *>(p_UserData));
   };
 
-  NCursesUserForm (NCursesFormField Fields[],
+  NCursesUserForm (NCursesFormField* Fields[],
 		   int nlines,
 		   int ncols,
 		   int begin_y = 0,
--- c++/cursesm.h.orig	2011-07-23 10:05:50.000000000 +0200
+++ c++/cursesm.h	2011-07-23 10:06:46.000000000 +0200
@@ -635,7 +635,7 @@
   }
 
 public:
-  NCursesUserMenu (NCursesMenuItem Items[],
+  NCursesUserMenu (NCursesMenuItem* Items[],
 		   const T* p_UserData = STATIC_CAST(T*)(0),
 		   bool with_frame=FALSE,
 		   bool autoDelete_Items=FALSE)
@@ -644,7 +644,7 @@
 	set_user (const_cast<void *>(p_UserData));
   };
 
-  NCursesUserMenu (NCursesMenuItem Items[],
+  NCursesUserMenu (NCursesMenuItem* Items[],
 		   int nlines,
 		   int ncols,
 		   int begin_y = 0,
EOF
}

# We don't want to be affected by ncurses libraries of the build system
EXTRA_CPPFLAGS=
EXTRA_CFLAGS=
EXTRA_LDFLAGS="-L$INSTALL_PREFIX/lib -Wl,-rpath,$INSTALL_PREFIX/lib"
CONFIGURE_VARS="										\\
	PKG_CONFIG_LIBDIR='$INSTALL_PREFIX/lib/pkgconfig'	\\
"
# - enable building shared libraries
# - generate normal manpages instead of those with .cx ext
# - suppress check for ada95
# - suppress check for ada95
# - compile with wide-char/UTF-8 code
# - --enable-overwrite,
# - compile in termcap fallback support
# - compile with SIGWINCH handler
CONFIGURE_ARGS="						\\
	--with-terminfo						\\
	--with-shared						\\
	--with-manpage-format=normal		\\
	--without-ada						\\
	--enable-widec						\\
	--enable-overwrite					\\
	--enable-termcap					\\
	--enable-sigwinch					\\
	--enable-pc-files					\\
	--mandir=$INSTALL_PREFIX/share/man	\\
"
