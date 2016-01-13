PKG_BUILD_DIR="$BASE_BUILD_DIR/lua-$PKG_VERSION"
PKG_STAGING_DIR="$BASE_DESTDIR/lua-$PKG_VERSION-install"
PKG_DEPENDS='readline ncurses'
LUA_DEFAULT_VERSION=5.1

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
	$MAKEJ $target test \
		MYCFLAGS="$EXTRA_CFLAGS" \
		MYLDFLAGS="$EXTRA_LDFLAGS" \
		MYLIBS="-ltermcap"
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
