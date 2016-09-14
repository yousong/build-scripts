#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
configure() {
	cd "$PKG_SOURCE_DIR"
	$PKG_SOURCE_DIR/bootstrap.sh
}

boost_b2() {
	local target="$1"
	local prefix="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local majmin="${PKG_VERSION%.*}"
	local libdir="$prefix/lib/boost-$majmin"
	local incdir="$prefix/include/boost-$majmin"

	cd "$PKG_BUILD_DIR"
	mkdir -p build
	#
	# -q, stop at first error
	#
	# stage only stages library files, not including header files
	#
	# See Boost.Build doc for details, http://www.boost.org/build/doc/html/bbv2/overview/invocation.html
	#
	$PKG_SOURCE_DIR/b2 \
		--prefix="$prefix" \
		--libdir="$libdir" \
		--includedir="$incdir" \
		--stagedir="$PKG_BUILD_DIR/stage" \
		--build-dir="$PKG_BUILD_DIR/build" \
		--layout=system \
		-j "$NJOBS" \
		-q \
		variant=release \
		cflags="$EXTRA_CFLAGS" \
		linkflags="$EXTRA_LDFLAGS" \
		"$target"
}

compile() {
	boost_b2 stage
}

staging() {
	boost_b2 install
}
