#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - Instructions of compilation and installation, https://wiki.openssl.org/index.php/Compilation_and_Installation
# - Changelog of 1.0.2, https://www.openssl.org/news/cl102.txt
#
PKG_NAME=openssl
PKG_VERSION=1.0.2t
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.openssl.org/source/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ef66581b80f06eae42f5268bc0b50c6d

# OpenSSL currently does not support parallel build
NJOBS=1
. "$PWD/env.sh"

configure() {
	local kern="$(uname -s)"
	local mach="$(uname -m)"
	local preset

	if [ "$kern" = Linux ]; then
		if [ "$mach" = x86_64 ]; then
			preset=linux-x86_64
		else
			preset=linux-x32
		fi
	elif [ "$kern" = Darwin ]; then
		if [ "$mach" = x86_64 ]; then
			preset=darwin64-x86_64-cc
		else
			preset=darwin-i386-cc
		fi
	fi

	cd "$PKG_BUILD_DIR"
	# "Configure" script is the one
	#
	# Run "Configure MAKE" and get more readable content from stdout
	eval MAKE="'${MAKEJ[*]}'" "$PKG_BUILD_DIR/Configure"	\
			--prefix="$INSTALL_PREFIX"		\
			--libdir="lib"				\
			shared "$preset"
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
Two ways to use system cert store

	# 1. symlink to the bundle (preferred)
	ln -sf /etc/ssl/certs/ca-bundle.trust.crt $INSTALL_PREFIX/ssl/certs/cert.pem

	# 2. symlink to those made by c_rehash
	rmdir $INSTALL_PREFIX/ssl/certs
	ln -sf /etc/ssl/certs $INSTALL_PREFIX/ssl/certs
"
}
