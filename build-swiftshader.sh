#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Requires
#
#	libX11-devel libXext-devel
#
# Prebuilt binaries are available for Linux and Windows
#
PKG_NAME=swiftshader
PKG_VERSION=2018-04-16
PKG_SOURCE_PROTO=git
PKG_SOURCE_URL="https://github.com/google/swiftshader.git"
PKG_SOURCE_VERSION=99be318ada3194e93d883a11c433fbea02ceb992
PKG_CMAKE=1

. "$PWD/env.sh"

# swiftshader CMakeLists.txt sets -fvisibility=protected" which causes link
# error on CentOS 7.4
#
#	/usr/bin/ld: CMakeFiles/libEGL.dir/src/OpenGL/libEGL/main.cpp.o: relocation R_X86_64_PC32 against protected symbol `libEGL_swiftshader' can not be used when making a shared object
#
# Linker decided to refuse linking because it sees potentially conflicting
# requirements
#
#  - We are building shared library with -fPIC which requires the symbol to be
#    relocatable (use GOT, or PLT, please correct me if it's wrong)
#  - GOT, PLT symbols can be interpositioned (overridden)
#  - But the .protected attribute means the shared library itself must use the
#    definition within the library (not to be overridden)
#
# Linker flag -Bsymbolic-functions, bind global function refs to the ones within the shared library, no symbol interposition (overridden)
#
# It's suggested that .protected symbols should be regarded by compiler and
# linker just like global visibility symbols using GOT, PLT entries, but let
# the dynamic linker do the resolution and preseve the c function pointer
# equlity requirement.
#
# Ref
#
# - Protected Symbols, https://www.airs.com/blog/archives/307
# - ld *can* link, it just chooses not to., https://gcc.gnu.org/bugzilla/show_bug.cgi?id=19520#c26
#
#
EXTRA_LDFLAGS+=(-Wl,-Bsymbolic-functions)

staging() {
	local prefix="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local incdir="$prefix/include"
	local libdir="$prefix/lib"

	mkdir -p "$libdir"
	mkdir -p "$incdir"
	cpdir "$PKG_SOURCE_DIR/include" "$incdir"
	for f in libEGL.so libGLES_CM.so libGLESv2.so; do
		cp "$PKG_BUILD_DIR/$f" "$libdir"
	done
}
