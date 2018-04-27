#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - Instructions of compilation and installation, https://wiki.openssl.org/index.php/Compilation_and_Installation
# - Changelog of 1.0.2, https://www.openssl.org/news/cl102.txt
#
PKG_NAME=openssl
PKG_VERSION=1.0.2n
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.openssl.org/source/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=13bdc1b1d1ff39b6fd42a255e74676a4

# OpenSSL currently does not support parallel build
NJOBS=1
. "$PWD/env.sh"

configure() {
	local kern="$(uname -s)"
	local mach="$(uname -m)"
	local os

	if [ "$kern" = Linux ]; then
		if [ "$mach" = x86_64 ]; then
			os=linux-x86_64
		else
			os=linux-x32
		fi
	elif [ "$kern" = Darwin ]; then
		if [ "$mach" = x86_64 ]; then
			os=darwin64-x86_64-cc
		else
			os=darwin-i386-cc
		fi
	fi

	cd "$PKG_BUILD_DIR"
	# "Configure" script is the one
	eval MAKE="'${MAKEJ[*]}'" "$PKG_BUILD_DIR/Configure"		\
			--prefix="$INSTALL_PREFIX"	\
			shared "$os"
	# make depend on each configure
	"${MAKEJ[@]}" depend
}

MAKE_VARS=(
	MANDIR="$INSTALL_PREFIX/share/man"
)
compile() {
	cd "$PKG_BUILD_DIR"

	"${MAKEJ[@]}" "${MAKE_VARS[@]}" all
}

staging() {
	cd "$PKG_BUILD_DIR"

	# OpenSSL use INSTALL_PREFIX instead of DESTDIR
	"${MAKEJ[@]}" install INSTALL_PREFIX="$PKG_STAGING_DIR" "${MAKE_VARS[@]}"
}

install_post() {
	__errmsg "
To use system cert store

	rmdir $INSTALL_PREFIX/ssl/certs
	ln -sf /etc/ssl/certs $INSTALL_PREFIX/ssl/certs
"
}
