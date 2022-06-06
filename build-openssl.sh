#!/bin/bash -e
#
# Copyright 2015-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - Instructions of compilation and installation, https://wiki.openssl.org/index.php/Compilation_and_Installation
# - Changelog of 1.0.2, https://www.openssl.org/news/cl102.txt
#
# Dependencies
#
# 	yum install -y perl-FindBin
#
#	# Test
#	yum install -y perl-Test-Most
#
#	# OpenSSL 3.0
#	yum install -y perl-IPC-Cmd
#
PKG_NAME=openssl
PKG_VERSION=1.1.1g
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.openssl.org/source/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=76766e98997660138cdaf13a187bd234

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

	# Run "Configure MAKE" and get more readable content from stdout
	CONFIGURE_CMD="$PKG_BUILD_DIR/Configure"
	CONFIGURE_ARGS+=(
		--libdir=lib
		shared
		"$preset"
	)
	cd "$PKG_BUILD_DIR"
	build_configure_default
}

compile() {
	cd "$PKG_BUILD_DIR"

	"${MAKEJ[@]}" "${MAKE_VARS[@]}" all
}

install_post() {
	__errmsg "
Two ways to use system cert store

	# 1. symlink to the bundle (preferred)
	ln -sf /etc/ssl/certs/ca-bundle.trust.crt $INSTALL_PREFIX/ssl/cert.pem

	# 2. symlink to those made by c_rehash
	rmdir $INSTALL_PREFIX/ssl/certs
	ln -sf /etc/ssl/certs $INSTALL_PREFIX/ssl/certs
"
}

ossl_test() {
	cd "$PKG_BUILD_DIR"
	# "${MAKEJ[@]}" test TESTS=test_evp
	# "${MAKEJ[@]}" test TESTS=test_evp V=1
	"${MAKEJ[@]}" test
}
