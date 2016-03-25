#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# All packages in toolchain supports out of source tree build
#
toolchain_init() {
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

	toolchain_prepare_extra() {
		local namedir="$(dirname "$PKG_SOURCE_DIR")"
		local namebase="$(basename "$PKG_SOURCE_DIR")"
		local name="${namebase%%-*}"

		# make symbolic link from gcc to gcc-x.y.z
		if [ ! -h "$namdir/$name" ]; then
			ln -snf "$namebase" "$namedir/$name"
		fi
	}

	toolchain_configure_pre() {
		mkdir -p "$PKG_BUILD_DIR"
	}

	clean_extra() {
		local namedir="$(dirname "$PKG_SOURCE_DIR")"
		local namebase="$(basename "$PKG_SOURCE_DIR")"
		local name="${namebase%%-*}"

		rm -f "$namedir/$name"
	}
}

toolchain_init_pkg() {
	true
}
