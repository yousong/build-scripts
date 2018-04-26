#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# All packages in toolchain supports out of source tree build
#
# Publicly available toolchains
#
# - Linaro toolchains for ARM and AAarch64,
#   https://releases.linaro.org/components/toolchain/binaries/
# - FreeElectrons toolchains built from Buildroot
#   http://toolchains.free-electrons.com/
# - Baremetal toolchains built by buildall script,
#   https://www.kernel.org/pub/tools/crosstool/
#
# TODO
#
# 17. Prepare symlinks for cross-gccgo
#
#	It also says in the golang wiki that a separate "go" tool will need to be
#	built with native gccgo to make it aware of the GOOS, GOARCh combination
#	supported by cross gccgo but not part of golang's own supported
#	combinations.  Figure out how this works to see whether if this is still
#	the case
#
# - https://github.com/golang/go/wiki/GccgoCrossCompilation
#
# 4. mconf support
# 5. strip toolchain
# 7. test build, with qemu user mode emulation at least
# 11. gcc enable-gold=default, enable-ld
#
# -L, -I, -Wl,--dynamic-linker=xxx.
#
# - For native toolchain, should search the directory relative to where the
#	driver was invoked first.
# - For cross, if we intend to run the built binaries in target machine, then
#	they should contain no host directory info.  Otherwise, for qemu-linux-user
#	emulation, it should
#
# Refs,
#
# - See gcc/config/i386/gnu-user.h for how LINK_SPEC is defined
# - See gcc/config/linux.h for definition of GNU_USER_DYNAMIC_LINKER
#
# multiarch and multilib
#
# 9. endian
# 13. lib64 dir
# 14. softfloat, hardfloat:
#     - binutils, --with-float=soft
#     - glibc, --with-fp, --without-fp
#     - gcc, --with-float
#     - https://gcc.gnu.org/wiki/Software_floating_point
#     - https://sourceware.org/ml/crossgcc/2011-11/msg00040.html
# 15. mips16 and o32, n32, n64
# 16, thumb
#
# - https://wiki.debian.org/Multiarch/TheCaseForMultiarch#Proposed_Solution
# - https://err.no/debian/amd64-multiarch-3
#
#   /lib64/ld-linux-x86-64.so.2 is the only file in /lib64 and it is a symbolic
#   link to /lib/x86_64-linux-gnu/ld-2.13.so
#
#	> lib64 is a wart on history and should never have been allowed to grow up
#
# setarch utility from util-linux allows to prepare an environ where uname
# output is customized
#
PKG_gcc_VERSION=7.3.0
PKG_gcc_SOURCE="gcc-$PKG_gcc_VERSION.tar.xz"
PKG_gcc_SOURCE_MD5SUM=be2da21680f27624f3a87055c4ba5af2
PKG_gcc_SOURCE_URL="http://ftpmirror.gnu.org/gcc/gcc-$PKG_gcc_VERSION/$PKG_gcc_SOURCE"

PKG_glibc_VERSION=2.27
PKG_glibc_SOURCE="glibc-$PKG_glibc_VERSION.tar.xz"
PKG_glibc_SOURCE_MD5SUM=898cd5656519ffbc3a03fe811dd89e82
PKG_glibc_SOURCE_URL="http://ftpmirror.gnu.org/glibc/$PKG_glibc_SOURCE"

PKG_binutils_VERSION=2.30
PKG_binutils_SOURCE="binutils-$PKG_binutils_VERSION.tar.xz"
PKG_binutils_SOURCE_MD5SUM=ffc476dd46c96f932875d1b2e27e929f
PKG_binutils_SOURCE_URL="http://ftpmirror.gnu.org/binutils/$PKG_binutils_SOURCE"

PKG_linux_VERSION=4.15.1
PKG_linux_SOURCE="linux-${PKG_linux_VERSION}.tar.xz"
PKG_linux_SOURCE_MD5SUM=e1a0defed7a7333ecb5715d63e9161a7
PKG_linux_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_linux_VERSION%%.*}.x/$PKG_linux_SOURCE"

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
#	riscv32-*-linux-gnu
#	riscv64-*-linux-gnu
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

TOOLCHAIN_DIR_BASE="$INSTALL_PREFIX/toolchain"
GNU_TOOLCHAIN_NAME="$TRI_TARGET"
GNU_TOOLCHAIN_NAME="${GNU_TOOLCHAIN_NAME}_gcc-${PKG_gcc_VERSION}"
GNU_TOOLCHAIN_NAME="${GNU_TOOLCHAIN_NAME}_glibc-${PKG_glibc_VERSION}"
GNU_TOOLCHAIN_NAME="${GNU_TOOLCHAIN_NAME}_binutils-${PKG_binutils_VERSION}"
GNU_TOOLCHAIN_DIR="$TOOLCHAIN_DIR_BASE/$GNU_TOOLCHAIN_NAME"
GNU_TOOLCHAIN_DIR_BIN="$GNU_TOOLCHAIN_DIR/bin"
GNU_TOOLCHAIN_DIR_LIB="$GNU_TOOLCHAIN_DIR/lib"
GNU_TOOLCHAIN_CC="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-gcc"
GNU_TOOLCHAIN_CXX="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-g++"


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
	STRIP=()
	if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
		PKG_BUILD_DIR="$BASE_BUILD_DIR/$GNU_TOOLCHAIN_NAME/$PKG_NAME"
		BASE_DESTDIR="$BASE_DESTDIR/$GNU_TOOLCHAIN_NAME"
	fi
	CONFIGURE_PATH="$PKG_BUILD_DIR"
	CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

	EXTRA_CPPFLAGS=()
	EXTRA_CFLAGS=()
	EXTRA_LDFLAGS=()
	TOOLCHAIN_DIR_BASE="$INSTALL_PREFIX/toolchain"
	TOOLCHAIN_DIR="$INSTALL_PREFIX/toolchain/$GNU_TOOLCHAIN_NAME"

	export PATH="$TOOLCHAIN_DIR/bin:$PATH"
	CONFIGURE_ARGS=(
		--prefix="$TOOLCHAIN_DIR"
	)

	case "$pkgname" in
		gcc-cross-pass1|gcc-cross-pass2)
			# setting default built compiler's options for -march=, -mabi, etc.
			# mips has at least 3 userland abi, i.e. o32, n32, n64 and
			# -mabi=n32 will be the default as can be seen from -dumpspecs
			# output.  Source code of libraries like libgo and libc will detect
			# and be compiled with the default abi by checking cpp macro
			# _MIPS_SIM against _ABI{O32,N32,N64,O64}, but we want a mips64
			# compiler with n64 as the default abi.
			#
			# The other thing is that there may exist a bug in autotools when
			# installing libgo.so to lib32/ directory where the symbolic link
			# creation happened before mkdir lib32/
			if [ "$TRI_ARCH" = "mips64" -o "$TRI_ARCH" = "mips64el" ]; then
				CONFIGURE_ARGS+=(
					--with-arch=mips64
					--with-abi=64
				)
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
	toolchain_init_genmake_func
}

toolchain_init_genmake_func() {
	toolchain_name() {
		echo "$GNU_TOOLCHAIN_NAME"
	}
	genmake_stampdir() {
		echo "\$(STAMP_DIR)/\$(shell $PKG_SCRIPT_NAME toolchain_name)"
	}
	genmake_logdir() {
		echo "\$(LOG_DIR)/\$(shell $PKG_SCRIPT_NAME toolchain_name)"
	}
}
