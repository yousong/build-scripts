#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
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
	local ver

	cd "$PKG_BUILD_DIR"
	for ver in $PKG_PYTHON_VERION; do
		python$ver setup.py build
	done
}

staging() {
	local ver

	cd "$PKG_BUILD_DIR"
	for ver in $PKG_PYTHON_VERION; do
		python$ver setup.py install --root="$PKG_STAGING_DIR" --prefix="$INSTALL_PREFIX"
	done
}
