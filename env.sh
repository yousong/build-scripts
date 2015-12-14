# the top level directory of these scripts
TOPDIR="${TOPDIR:-$PWD}"
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

os_is_darwin() {
	[ "$(uname -o)" = "Darwin" ]
}

os_is_linux() {
	[ "$(uname -o)" = "GNU/Linux" ]
}

ncpus() {
	if os_is_darwin; then
		sysctl -n hw.logicalcpu
	elif os_is_linux; then
		# nproc is part of coreutils
		nproc || cat /proc/cpuinfo  | grep '^processor\s\+:' | wc -l
	else
		__errmsg "os not supported"
	fi
}

_init() {
    mkdir -p "$BASE_DL_DIR"
    mkdir -p "$BASE_BUILD_DIR"
    mkdir -p "$BASE_DESTDIR"
    mkdir -p "$INSTALL_PREFIX"

    alias cp="cp -a -T"
	export PKG_CONFIG_PATH="$INSTALL_PREFIX/lib/pkgconfig:$INSTALL_PREFIX/share/pkgconfig"
	EXTRA_CPPFLAGS="-I$INSTALL_PREFIX/include"
	EXTRA_CFLAGS="-I$INSTALL_PREFIX/include"
	EXTRA_LDFLAGS="-L$INSTALL_PREFIX/lib -Wl,-rpath,$INSTALL_PREFIX/lib"
	if os_is_darwin; then
		MACPORTS_PREFIX="${MACPORTS_PREFIX:-/opt/local}"
		export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$MACPORTS_PREFIX/lib/pkgconfig"
		export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$MACPORTS_PREFIX/share/pkgconfig"
		EXTRA_CPPFLAGS="$EXTRA_CPPFLAGS -I$MACPORTS_PREFIX/include"
		EXTRA_CFLAGS="$EXTRA_CFLAGS -I$MACPORTS_PREFIX/include"
		EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L$MACPORTS_PREFIX/lib -Wl,-rpath,$MACPORTS_PREFIX/lib"
	fi
	NJOBS="${NJOBS:-$((2 * $(ncpus)))}"
}
_init

PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME-$PKG_VERSION"
_PKG_STAGING_DIR="$BASE_DESTDIR/$PKG_NAME-$PKG_VERSION-install"

_csum_check() {
	local file="$1"
	local csum

	csum="$(md5sum "$file" | cut -f1 -d' ')"
	if [ -z "$PKG_SOURCE_MD5SUM" -o "$csum" = "$PKG_SOURCE_MD5SUM" ]; then
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

download_extra() {
	true
}

download() {
	download_http
	download_extra
}

untar() {
	local file="$1"
	local dir="$2"
	local trans_exp="$3"
	local fn="$(basename $file)"
	local ftyp opts

	# The following options are only supported by GNU tar.
	#
	#	--transform
	#	--gzip (-z)
	#	--bzip2 (-j)
	#	--xz (-J)
	#
	# The MacPorts package name is gnutar
	case "$fn" in
		*.tar.gz|*.tgz)
			ftyp="--gzip"
			;;
		*.tar.bz2)
			ftyp="--bzip2"
			;;
		*.tar.xz)
			ftyp="--xz"
			;;
		*)
			__errmsg "unknown file type: $file"
			return 1
			;;
	esac
	[ ! -d "$dir" ] || opts="$opts -C $dir"
	[ -z "$trans_exp" ] || opts="$opts --transform=$trans_exp"
	tar $opts $ftyp -xf "$file"
}

prepare_source() {
		untar "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR"
}

prepare_extra() {
	true
}

do_patch() {
	true
}

prepare() {
	if [ -d "$PKG_BUILD_DIR" ]; then
		__errmsg "$PKG_BUILD_DIR already exists, skip preparing."
	else
		rm -rf "$PKG_BUILD_DIR"
		prepare_source
		prepare_extra
		do_patch
	fi
}

build_pre() {
	true
}

build_configure_default() {
	cd "$PKG_BUILD_DIR"
	eval CPPFLAGS="'$EXTRA_CPPFLAGS'"	\
		 CFLAGS="'$EXTRA_CFLAGS'"		\
		 LDFLAGS="'$EXTRA_LDFLAGS'"		\
		 "$CONFIGURE_VARS"				\
		 "$PKG_BUILD_DIR/configure"		\
			--prefix="$INSTALL_PREFIX"	\
			"$CONFIGURE_ARGS"
}

build_configure_cmake() {
	cd "$PKG_BUILD_DIR"

	eval cmake												\
		-DCMAKE_BUILD_TYPE=Release							\
		-DCMAKE_INSTALL_PREFIX="'$INSTALL_PREFIX'"			\
		-DCMAKE_EXE_LINKER_FLAGS="'$EXTRA_LDFLAGS'"			\
		-DCMAKE_SHARED_LINKER_FLAGS="'$EXTRA_LDFLAGS'"		\
		-DCMAKE_C_FLAGS="'$EXTRA_CFLAGS'"					\
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=on					\
		-DCMAKE_MACOSX_RPATH=on								\
		$CMAKE_ARGS
}

build_configure() {
	if [ -n "$PKG_CMAKE" ]; then
		build_configure_cmake
	else
		build_configure_default
	fi
}

build_compile() {
	cd "$PKG_BUILD_DIR"
	eval CFLAGS="'$EXTRA_CFLAGS'" CPPFLAGS="'$EXTRA_CPPFLAGS'" LDFLAGS="'$EXTRA_LDFLAGS'" "$MAKE_VARS" \
		make -j "$NJOBS" ${PKG_CMAKE:+VERBOSE=1} "$MAKE_VARS"
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

install_staging() {
	cd "$PKG_BUILD_DIR"
	eval "$MAKE_VARS" \
		make -j "$NJOBS" install DESTDIR="$_PKG_STAGING_DIR" ${PKG_CMAKE:+VERBOSE=1} "$MAKE_VARS"
}

install_post() {
	true
}

install_to_final() {
	mkdir -p "$INSTALL_PREFIX"
	cp "$_PKG_STAGING_DIR/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

install() {
	rm -rf "$_PKG_STAGING_DIR"
	install_pre
	install_staging
	install_post
	install_to_final
}

main() {
	download
	prepare
	build
	install
}
