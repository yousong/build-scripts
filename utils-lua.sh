#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_DEPENDS='readline ncurses'
LUA_DEFAULT_VERSION=5.1

lua_do_patch() {
	true
}

do_patch() {
	cd "$PKG_SOURCE_DIR"

	lua_do_patch
	# LUA_PATH_DEFAULT and LUA_CPATH_DEFAULT has './?.so' at the front for lua5.1
	# while at the end for lua5.2 and lua5.3
	sed -i'' -e 's:^\(#define LUA_ROOT	\).*$:\1"'"$INSTALL_PREFIX/"'":' src/luaconf.h
}

configure() {
	true
}

compile() {
	local target

	cd "$PKG_BUILD_DIR"
	if os_is_linux; then
		target=linux
	elif os_is_darwin; then
		target=macosx
	else
		__errmsg 'unknown system'
		false
	fi
	$MAKEJ $target \
		MYCFLAGS="$EXTRA_CFLAGS" \
		MYLDFLAGS="$EXTRA_LDFLAGS" \
		MYLIBS="-ltermcap"
	$MAKEJ test
}

staging() {
	cd "$PKG_BUILD_DIR"
	$MAKEJ echo install \
		INSTALL_TOP="$PKG_STAGING_DIR$INSTALL_PREFIX" \
		INSTALL_INC="$PKG_STAGING_DIR$INSTALL_PREFIX/include/$PKG_NAME" \
		INSTALL_LIB="$PKG_STAGING_DIR$INSTALL_PREFIX/lib/$PKG_NAME" \
		INSTALL_MAN="$PKG_STAGING_DIR$INSTALL_PREFIX/share/man/man1"
}

staging_post() {
	local prefix="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local ver="${PKG_VERSION%.*}"

	mkdir -p "$prefix/lib/pkgconfig"
	cat >"$prefix/lib/pkgconfig/$PKG_NAME.pc" <<EOF
Name: Lua
Description: An Extensible Extension Language
Version: $PKG_VERSION
Requires:
Libs: -L${INSTALL_PREFIX}/lib/$PKG_NAME -llua -lm
Cflags: -I${INSTALL_PREFIX}/include/$PKG_NAME
EOF

	# Provide versioned suffix for binaries and manuals
	mv "$prefix/bin/lua" "$prefix/bin/lua$ver"
	mv "$prefix/bin/luac" "$prefix/bin/luac$ver"
	mv "$prefix/share/man/man1/lua.1" "$prefix/share/man/man1/lua$ver.1"
	mv "$prefix/share/man/man1/luac.1" "$prefix/share/man/man1/luac$ver.1"
	# Create symbolic links for the default version
	if [ "$ver" = "$LUA_DEFAULT_VERSION" ]; then
		ln -s "lua$ver" "$prefix/bin/lua"
		ln -s "luac$ver" "$prefix/bin/luac"
		ln -s "$PKG_NAME.pc" "$prefix/lib/pkgconfig/lua.pc"
		ln -s "lua$ver.1" "$prefix/share/man/man1/lua.1"
		ln -s "luac$ver.1" "$prefix/share/man/man1/luac.1"
	fi
}
