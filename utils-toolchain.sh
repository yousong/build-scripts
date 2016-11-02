#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# All packages in toolchain supports out of source tree build
#
# TODO
#
# 4. mconf support
# 5. strip toolchain
#
PKG_gcc_VERSION=6.2.0
PKG_gcc_SOURCE="gcc-$PKG_gcc_VERSION.tar.bz2"
PKG_gcc_SOURCE_MD5SUM=9768625159663b300ae4de2f4745fcc4
PKG_gcc_SOURCE_URL="http://ftpmirror.gnu.org/gcc/gcc-$PKG_gcc_VERSION/$PKG_gcc_SOURCE"

PKG_glibc_VERSION=2.24
PKG_glibc_SOURCE="glibc-$PKG_glibc_VERSION.tar.xz"
PKG_glibc_SOURCE_MD5SUM=97dc5517f92016f3d70d83e3162ad318
PKG_glibc_SOURCE_URL="http://ftpmirror.gnu.org/glibc/$PKG_glibc_SOURCE"

PKG_binutils_VERSION=2.27
PKG_binutils_SOURCE="binutils-$PKG_binutils_VERSION.tar.bz2"
PKG_binutils_SOURCE_MD5SUM=2869c9bf3e60ee97c74ac2a6bf4e9d68
PKG_binutils_SOURCE_URL="http://ftpmirror.gnu.org/binutils/$PKG_binutils_SOURCE"

PKG_linux_VERSION=4.4.27
PKG_linux_SOURCE="linux-${PKG_linux_VERSION}.tar.xz"
PKG_linux_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_linux_VERSION%%.*}.x/$PKG_linux_SOURCE"
PKG_linux_SOURCE_MD5SUM=3d45ce46c2c6b260feee53bae94aca0d

#
# check config.sub and gcc/config.gcc for available target combinations
#
# compile-tested targets:
#
#	i686-*-linux-gnu
#	x86_64-*-linux-gnu
#
#	mips-*-linux-gnu
#	mipsel-*-linux-gnu
#	mips64-*-linux-gnu
#	mips64el-*-linux-gnu
#
#	arm-*-linux-gnueabi
#	arm-*-linux-gnueabihf
#	armeb-*-linux-gnueabi
#	armeb-*-linux-gnueabihf
#	aarch64-*-linux-gnu
#	aarch64_be-*-linux-gnu
#
# arm kernel header with aarch64 toolchain does not work because assembler will
# complain "immediate cannot be moved by a single instruction" in "mov x8,
# ((__NR_SYSCALL_BASE+37))" when compiling glibc where __NR_SYSCALL_BASE will
# be defined as 0x900000 (__NR_OABI_SYSCALL_BASE) in include/asm/unistd.h
#
TRI_ARCH="${TRI_ARCH:-x86_64}"
TRI_OPSYS="${TRI_OPSYS:-linux-gnu}"
TRI_BUILD="$(gcc -dumpmachine)"
TRI_HOST="$TRI_BUILD"
TRI_TARGET="$TRI_ARCH-bs-$TRI_OPSYS"

TOOLCHAIN_NAME="$TRI_TARGET"
TOOLCHAIN_NAME="${TOOLCHAIN_NAME}_gcc-${PKG_gcc_VERSION}"
TOOLCHAIN_NAME="${TOOLCHAIN_NAME}_glibc-${PKG_glibc_VERSION}"
TOOLCHAIN_NAME="${TOOLCHAIN_NAME}_binutils-${PKG_binutils_VERSION}"

toolchain_init_pkg() {
	local pkg="$1"

	case "$pkg" in
		gcc|glibc|binutils|linux)
			eval "PKG_VERSION=\$PKG_${pkg}_VERSION"
			eval "PKG_SOURCE=\$PKG_${pkg}_SOURCE"
			eval "PKG_SOURCE_MD5SUM=\$PKG_${pkg}_SOURCE_MD5SUM"
			eval "PKG_SOURCE_URL=\$PKG_${pkg}_SOURCE_URL"
			;;
		*)
			echo "unknown package %s" >&2
			return 1
			;;
	esac
}

toolchain_configure_pre() {
	mkdir -p "$PKG_BUILD_DIR"
}

toolchain_clean() {
	rm -rf "$PKG_BUILD_DIR"
}

toolchain_init_vars_build_cross() {
	local pkgname="$1"

	# stripping host/target toolchain can be tricky, leave it alone for now
	unset STRIP
	if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
		PKG_BUILD_DIR="$BASE_BUILD_DIR/$TOOLCHAIN_NAME/$PKG_NAME"
		BASE_DESTDIR="$BASE_DESTDIR/$TOOLCHAIN_NAME"
	fi
	CONFIGURE_PATH="$PKG_BUILD_DIR"
	CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

	EXTRA_CPPFLAGS=
	EXTRA_CFLAGS=
	EXTRA_LDFLAGS=
	TOOLCHAIN_DIR_BASE="$INSTALL_PREFIX/toolchain"
	TOOLCHAIN_DIR="$INSTALL_PREFIX/toolchain/$TOOLCHAIN_NAME"

	export PATH="$TOOLCHAIN_DIR/bin:$PATH"
	CONFIGURE_ARGS="--prefix='$TOOLCHAIN_DIR'		\\
	"

	case "$pkgname" in
		gcc-cross-pass1|gcc-cross-pass2)
			# setting default built compiler's options for -march=, -mabi, etc.
			# mips has at least 3 userland abi, i.e. o32, n32, n64 and
			# -mabi=n32 will be the default as can be seen from -dumpspecs
			# output.  Libraries like libgo and libc will detect and compile
			# with the default abi by checking cpp macro _MIPS_SIM against
			# _ABI{O32,N32,N64,O64}.  But we want a mips64 compiler with n64 as
			# the default abi.
			#
			# The other thing is that there may exist a bug in autotools when
			# installing libgo.so to lib32/ directory where the symbolic link
			# creation happened before mkdir lib32/
			if [ "$TRI_ARCH" = "mips64" -o "$TRI_ARCH" = "mips64el" ]; then
				CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
					--with-arch=mips64				\\
					--with-abi=64					\\
				"
			fi
			;;
	esac

	case "$pkgname" in
		binutils-cross|gcc-cross-pass*)
			download() {
				true
			}

			prepare() {
				true
			}

			configure_pre() {
				toolchain_configure_pre
			}

			clean() {
				toolchain_clean
			}
			;;
		glibc-cross)
			configure_pre() {
				toolchain_configure_pre
			}
			;;
	esac
}
