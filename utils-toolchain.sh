#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# All packages in toolchain supports out of source tree build
#
toolchain_init_pkg() {
	local pkg="$1"

	case "$pkg" in
		gcc)
			PKG_VERSION=6.2.0
			PKG_SOURCE_MD5SUM=9768625159663b300ae4de2f4745fcc4
			PKG_SOURCE="$pkg-$PKG_VERSION.tar.bz2"
			PKG_SOURCE_URL="http://ftpmirror.gnu.org/gcc/gcc-$PKG_VERSION/$PKG_SOURCE"
			;;
		binutils)
			PKG_VERSION=2.27
			PKG_SOURCE_MD5SUM=2869c9bf3e60ee97c74ac2a6bf4e9d68
			PKG_SOURCE="$pkg-$PKG_VERSION.tar.bz2"
			PKG_SOURCE_URL="http://ftpmirror.gnu.org/binutils/$PKG_SOURCE"
			;;
		glibc)
			PKG_VERSION=2.24
			PKG_SOURCE_MD5SUM=97dc5517f92016f3d70d83e3162ad318
			PKG_SOURCE="$pkg-$PKG_VERSION.tar.xz"
			PKG_SOURCE_URL="http://ftpmirror.gnu.org/glibc/$PKG_SOURCE"
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

	if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
		PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME"
	fi
	CONFIGURE_PATH="$PKG_BUILD_DIR"
	CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

	TRI_BUILD=x86_64-pc-linux-gnu
	TRI_HOST=x86_64-pc-linux-gnu
	TRI_TARGET=x86_64-bs-linux-gnu

	EXTRA_CPPFLAGS=
	EXTRA_CFLAGS=
	EXTRA_LDFLAGS=
	TOOLCHAIN_DIR_BASE="$INSTALL_PREFIX/toolchain"
	TOOLCHAIN_DIR="$INSTALL_PREFIX/toolchain/$TRI_TARGET"

	export PATH="$TOOLCHAIN_DIR/bin:$PATH"
	CONFIGURE_ARGS="--prefix='$TOOLCHAIN_DIR'		\\
	"

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

toolchain_init_vars_build_native() {
	local pkgname="$1"
	local binutils_pass1_inst="$INSTALL_PREFIX/binutils-pass1"

	if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
		PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME"
	fi
	CONFIGURE_PATH="$PKG_BUILD_DIR"
	CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

	case "$pkgname" in
		binutils-native-pass1)
			CONFIGURE_ARGS="--prefix=$binutils_pass1_inst"
			;;
		glibc-native)
			# ld-x86_64.so.2 does not like RPATH: will choke with
			#
			#	Inconsistency detected by ld.so: dl-lookup.c: 867: _dl_setup_hash: Assertion `(bitmask_nwords & (bitmask_nwords - 1)) == 0' failed!
			#
			EXTRA_CPPFLAGS=''
			EXTRA_CFLAGS="$EXTRA_CFLAGS -O2"
			EXTRA_LDFLAGS=''
			CONFIGURE_ARGS="$CONFIGURE_ARGS					\\
				--enable-kernel=2.6.32						\\
				--disable-werror							\\
			"
			if [ "${PKG_DEPENDS%*binutils-native-pass1}" != "$PKG_DEPENDS" ]; then
				export PATH="$binutils_pass1_inst/bin:$PATH"
				install_post() {
					# local var binutils_pass1_inst cannot be used here
					rm -rf "$INSTALL_PREFIX/binutils-pass1"
				}
			fi
			;;
		*)
			EXTRA_LDFLAGS="$EXTRA_LDFLAGS -Wl,--dynamic-linker=$INSTALL_PREFIX/lib/ld-linux-x86-64.so.2"
			;;
	esac

	case "$pkgname" in
		binutils-native-*)
			CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
				--enable-plugins					\\
				--disable-multilib					\\
				--disable-werror					\\
				--disable-nls						\\
				--disable-sim						\\
				--disable-gdb						\\
			"
			;;
	esac

	case "$pkgname" in
		binutils-native-*|gcc-native)
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
	esac
}
