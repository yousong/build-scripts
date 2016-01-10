utils_python_init() {
	local ver

	for ver in $PKG_PYTHON_VERION; do
		PKG_DEPENDS="$PKG_DEPENDS python$ver"
	done
}
utils_python_init

configure() {
	true
}

compile() {
	true
}

staging() {
	local ver
	cd "$PKG_BUILD_DIR"

	for ver in $PKG_PYTHON_VERION; do
		python$ver setup.py install --root="$PKG_STAGING_DIR" --prefix="$INSTALL_PREFIX"
	done
}
