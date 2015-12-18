#!/bin/sh -e
#
# - Instructions of compilation and installation, https://wiki.openssl.org/index.php/Compilation_and_Installation
#
PKG_NAME=openssl
PKG_VERSION=1.0.2e
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.openssl.org/source/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5262bfa25b60ed9de9f28d5d52d77fc5

. "$PWD/env.sh"

# OpenSSL currently does not support parallel build
NJOBS=1
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
	eval "$PKG_BUILD_DIR/Configure"		\
			--prefix="$INSTALL_PREFIX"	\
			shared "$os"
	# make depend on each configure
	make depend
}

compile() {
	cd "$PKG_BUILD_DIR"

	eval make -j "$NJOBS" \
		"$MAKE_VARS" \
		all
}

staging() {
	cd "$PKG_BUILD_DIR"

	# OpenSSL use INSTALL_PREFIX instead of DESTDIR
	eval "$MAKE_VARS" \
		make -j "$NJOBS" install INSTALL_PREFIX="$PKG_STAGING_DIR" "$MAKE_VARS"
}

