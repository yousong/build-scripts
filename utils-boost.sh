#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_DEPENDS="$PKG_DEPENDS bzip2"

BOOST_MAJMIN="${PKG_VERSION%.*}"
BOOST_PREFIX="$PKG_STAGING_DIR$INSTALL_PREFIX/boost/boost-$BOOST_MAJMIN"
BOOST_LIBDIR="$BOOST_PREFIX/lib"
BOOST_INCDIR="$BOOST_PREFIX/include"
BOOST_EXTRA_CFLAGS=(
	"${EXTRA_CFLAGS[@]}"
	-I"$BOOST_PREFIX/include"
)
BOOST_EXTRA_LDFLAGS=(
	"${EXTRA_LDFLAGS[@]}"
	-L"$BOOST_PREFIX/lib" -Wl,-rpath,"$BOOST_PREFIX/lib"
)

configure() {
	cd "$PKG_SOURCE_DIR"
	$PKG_SOURCE_DIR/bootstrap.sh
}

boost_b2() {
	local target="$1"

	cd "$PKG_BUILD_DIR"
	mkdir -p build
	#
	# -q, stop at first error
	#
	# stage only stages library files, not including header files
	#
	# See Boost.Build doc for details, http://www.boost.org/build/doc/html/bbv2/overview/invocation.html
	#
	# NJOBS can be undefined if running_in_make
	#
	$PKG_SOURCE_DIR/b2 \
		--prefix="$BOOST_PREFIX" \
		--libdir="$BOOST_LIBDIR" \
		--includedir="$BOOST_INCDIR" \
		--stagedir="$PKG_BUILD_DIR/stage" \
		--build-dir="$PKG_BUILD_DIR/build" \
		--layout=system \
		${NJOBS:+-j "$NJOBS"} \
		-q \
		variant=release \
		cflags="${BOOST_EXTRA_CFLAGS[*]}" \
		linkflags="${BOOST_EXTRA_LDFLAGS[*]}" \
		"$target"
}

compile() {
	boost_b2 stage
}

staging() {
	boost_b2 install
}
