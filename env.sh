# where to do the build
TOPDIR="${TOPDIR:-$PWD}"
NJOBS=32

# where to put source code.
BASE_DL_DIR="${BASE_DL_DIR:-$TOPDIR/dl}"
# where to do the build.
BASE_BUILD_DIR="${BASE_BUILD_DIR:-$TOPDIR/build_dir}"
# where to stage the install
BASE_DESTDIR="${BASE_DESTDIR:-$TOPDIR/dest_dir}"
# where to do the final install
INSTALL_PREFIX="${INSTALL_PREFIX:-$HOME/.usr}"


__errmsg() {
    echo "$1" >&2
}

_init() {
    mkdir -p "$BASE_DL_DIR"
    mkdir -p "$BASE_BUILD_DIR"
    mkdir -p "$BASE_DESTDIR"
    mkdir -p "$INSTALL_PREFIX"

    alias cp="cp -a -T"
	export PKG_CONFIG_PATH="$INSTALL_PREFIX/lib/pkgconfig:$INSTALL_PREFIX/share/pkgconfig"
}
_init

PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME-$PKG_VERSION"
_PKG_STAGING_DIR="$BASE_DESTDIR/$PKG_NAME-$PKG_VERSION-install"

_csum_check() {
	local file="$1"
	local csum

	csum="$(md5sum "$file" | cut -f1 -d' ')"
	if [ "$csum" = "$PKG_SOURCE_MD5SUM" ]; then
		return 0
	else
		__errmsg "md5sum not match"
		__errmsg ""
		__errmsg "        file: $file"
		__errmsg "    expected: $PKG_SOURCE_MD5SUM"
		__errmsg "      actual: $csum"
		return 1
	fi
}

download_http() {
	local file="$BASE_DL_DIR/$PKG_SOURCE"
	local tmp="$file.dl"

	# expecting set -e will abort if anything bad happens
	if [ -f "$file" ]; then
		if _csum_check "$file"; then
			return 0
		else
			return 1
		fi
	fi
	wget -c -O "$tmp" "$PKG_SOURCE_URL"
	mv "$tmp" "$file"
	_csum_check "$file"
}

download() {
	download_http
}

prepare_build_dir() {
	local file="$BASE_DL_DIR/$PKG_SOURCE"
	local fn="$PKG_SOURCE"

	rm -rf "$PKG_BUILD_DIR"
	case "$fn" in
		*.tar.gz|*.tgz)
			tar -C "$BASE_BUILD_DIR" -xzf "$file"
			;;
		*.tar.bz2)
			tar -C "$BASE_BUILD_DIR" -xjf "$file"
			;;
		*.tar.xz)
			tar -C "$BASE_BUILD_DIR" -xJf "$file"
			;;
		*)
			__errmsg "unknown file type: $file"
			return 1
			;;
	esac
}

do_patch() {
	true
}

prepare() {
	if [ -d "$PKG_BUILD_DIR" ]; then
		__errmsg "$PKG_BUILD_DIR already exists, skip preparing."
		return 0
	else
		prepare_build_dir
		do_patch
	fi
}

build_pre() {
	true
}

build_configure() {
	cd "$PKG_BUILD_DIR"
	eval "$PKG_BUILD_DIR/configure"        \
		--prefix="$INSTALL_PREFIX"         \
		"$CONFIGURE_ARGS"
}

build_compile() {
	cd "$PKG_BUILD_DIR"
	eval make -j "$NJOBS" "$MAKE_VARS"
}

build_post() {
	true
}

build() {
	build_pre

	build_configure
	build_compile

	build_post
}

install_pre() {
	true
}

install_do() {
	cd "$PKG_BUILD_DIR"
	make DESTDIR="$_PKG_STAGING_DIR" install
	cp "$_PKG_STAGING_DIR/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

install_post() {
	true
}

install() {
	rm -rf "$_PKG_STAGING_DIR"
	install_pre
	install_do
	install_post
}

main() {
	download
	prepare
	build
	install
}
