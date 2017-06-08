#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - 2.9 Installing MySQL from Source, http://dev.mysql.com/doc/refman/5.7/en/source-installation.html
# - 2.9.4 MySQL Source-Configuration Options, http://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html
#
PKG_NAME=percona-server
PKG_VERSION=5.7.14-7
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.percona.com/downloads/Percona-Server-${PKG_VERSION%.*}/Percona-Server-$PKG_VERSION/source/tarball/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b0ce44b70f248964789e2df0ddf1b89b
PKG_DEPENDS='boost1.59 ncurses readline'
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- storage/tokudb/PerconaFT/CMakeLists.txt.orig	2016-09-14 17:33:32.275657031 +0800
+++ storage/tokudb/PerconaFT/CMakeLists.txt	2016-09-14 17:33:43.763660626 +0800
@@ -82,7 +82,7 @@ add_subdirectory(tools)
 
 install(
   FILES README.md COPYING.AGPLv3 COPYING.GPLv2 PATENTS
-  DESTINATION .
+  DESTINATION ${INSTALL_DOCREADMEDIR}
   COMPONENT tokukv_misc
   )
 
EOF
}

percona_share="$INSTALL_PREFIX/share/$PKG_NAME"
CMAKE_ARGS="$CMAKE_ARGS			\\
	-DCMAKE_INSTALL_LAYOUT=RPM	\\
	-DINSTALL_INFODIR=$INSTALL_PREFIX/share/info			\\
	-DINSTALL_DOCDIR=$percona_share							\\
	-DINSTALL_DOCREADMEDIR=$percona_share					\\
	-DINSTALL_MYSQLSHAREDIR=$percona_share					\\
	-DINSTALL_MYSQLTESTDIR=$percona_share/mysql-test		\\
	-DINSTALL_SUPPORTFILESDIR=$percona_share/support-files	\\
"

# The following command
#
#	COMMAND ${ETAGS} -o TAGS ${all_srcs} ${all_hdrs}
#
# will cause
#
#	make[4]: execvp: /bin/sh: Argument list too long
#
CMAKE_ARGS="$CMAKE_ARGS		\\
	-DUSE_CTAGS=OFF			\\
	-DUSE_ETAGS=OFF			\\
	-DUSE_GTAGS=OFF			\\
	-DUSE_CSCOPE=OFF		\\
	-DUSE_MKID=OFF			\\
"

boost1_59_lib="$INSTALL_PREFIX/lib/boost-1.59"
boost1_59_inc="$INSTALL_PREFIX/include/boost-1.59"
if [ -d "$boost1_59_lib" -a -d $boost1_59_inc ]; then
	EXTRA_LDFLAGS="$EXTRA_LDFLAGS	\
		-L'$boost1_59_lib'			\
		-Wl,-rpath,'$boost1_59_lib'	\
	"
	CMAKE_ARGS="$CMAKE_ARGS						\\
		-DBOOST_INCLUDE_DIR='$boost1_59_inc'	\\
	"
fi
