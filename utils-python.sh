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
