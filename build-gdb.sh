#!/bin/sh -e

PKG_NAME=gdb
PKG_VERSION=7.10.1
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/gdb/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=39e654460c9cdd80200a29ac020cfe11

. "$PWD/env.sh"

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

CONFIGURE_ARGS='			\
	--with-python			\
'
