#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# tarballs of golang are prefixed with go/ without version information
PKG_SOURCE_UNTAR_FIXUP=1

GO_RELEASE_VER="${PKG_VERSION%.*}"
GOROOT_FINAL="$INSTALL_PREFIX/go/goroot-$PKG_VERSION"
# most files in go are not compiled by GNU tools...  It may happen that
#
#	strip: Unable to recognise the format of the input file
#
# even though `file` utility recognizes them
STRIP=()

configure() {
	true
}

compile() {
	# ianlancetaylor:
	#
	# > You are only going to use Go 1.4 to build a newer release of Go. That
	# > test failure does not matter. We are not going to ensure that all Go 1.4
	# > tests continue to pass when using newer compilers and newer operating
	# > system versions. We are only going to ensure that Go 1.4 works to build
	# > newer releases of Go, and ensure that the tests of those newer releases
	# > pass.
	#
	# > The instructions do not recommend that you run the Go 1.4 all.bash. I
	# > don't recommend it either. If you choose to follow that path, I'm afraid
	# > that you are on your own.
	#
	# https://github.com/golang/go/issues/18771#issuecomment-274879224
	local script
	if [ "$GO_RELEASE_VER" = "1.4" ]; then
		script=make.bash
	else
		script=all.bash
	fi

	cd "$PKG_SOURCE_DIR/src"
	# --no-clean is for avoiding passing -a option to `go tool dist bootstrap`
	# to avoid "rebuild all"
	#
	# use make.bash on lowmem machine
	GOROOT_FINAL="$GOROOT_FINAL" \
		GOROOT_BOOTSTRAP="$GOROOT_BOOTSTRAP" \
		"./$script" --no-clean
}

staging() {
	local d="$PKG_STAGING_DIR$GOROOT_FINAL"

	mkdir -p "$d"
	cpdir "$PKG_SOURCE_DIR" "$d"
}

install() {
	local d="$PKG_STAGING_DIR$GOROOT_FINAL"

	mkdir -p "$GOROOT_FINAL"
	cpdir "$d" "$GOROOT_FINAL"
}
