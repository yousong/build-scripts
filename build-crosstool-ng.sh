#!/bin/sh -e
#
# crosstool-ng needs gperf and makeinfo
#
#	yum install -y gperf texinfo
#
# On Mac OS X, objdump and objcopy from binutils are needed,
#  https://sourceware.org/ml/crossgcc/2010-05/msg00121.html
#
PKG_NAME=crosstool-ng
PKG_VERSION=1.21.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://crosstool-ng.org/download/crosstool-ng/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=436c95ce91a9140fa03ddb32fc0db3f5
PKG_DEPENDS='ncurses5'

. "$PWD/env.sh"

# - To prevent false "Recursive detection" failing out
# - To solve -Idir missing when building kconfig/
# - libncurses.a requries -ldl
MAKE_VARS="					\\
	MAKELEVEL=0				\\
	EXTRA_CFLAGS='$EXTRA_CFLAGS'		\\
	EXTRA_LDFLAGS='$EXTRA_LDFLAGS -ldl'	\\
"
