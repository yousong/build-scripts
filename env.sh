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
	PKG_CONFIG_PATH="$INSTALL_PREFIX/lib/pkgconfig:$INSTALL_PREFIX/share/pkgconfig"
	EXTRA_CPPFLAGS="-I$INSTALL_PREFIX/include"
	EXTRA_CFLAGS="-I$INSTALL_PREFIX/include"
	EXTRA_LDFLAGS="-L$INSTALL_PREFIX/lib -Wl,-rpath,$INSTALL_PREFIX/lib"
	if [ -d "$INSTALL_PREFIX/lib64" ]; then
		PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$INSTALL_PREFIX/lib64/pkgconfig"
		EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L$INSTALL_PREFIX/lib64 -Wl,-rpath,$INSTALL_PREFIX/lib64"
	fi
	if os_is_darwin; then
		# ld: -rpath can only be used when targeting Mac OS X 10.5 or later
		export MACOSX_DEPLOYMENT_TARGET="10.5"
		MACPORTS_PREFIX="${MACPORTS_PREFIX:-/opt/local}"
		PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$MACPORTS_PREFIX/lib/pkgconfig"
		PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$MACPORTS_PREFIX/share/pkgconfig"
		EXTRA_CPPFLAGS="$EXTRA_CPPFLAGS -I$MACPORTS_PREFIX/include"
		EXTRA_CFLAGS="$EXTRA_CFLAGS -I$MACPORTS_PREFIX/include"
		EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L$MACPORTS_PREFIX/lib -Wl,-rpath,$MACPORTS_PREFIX/lib"
	fi
	export PKG_CONFIG_PATH
	NJOBS="${NJOBS:-$((2 * $(ncpus)))}"
}
_init

PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME-$PKG_VERSION"
PKG_STAGING_DIR="$BASE_DESTDIR/$PKG_NAME-$PKG_VERSION-install"

_csum_check() {
	local file="$1"
	local xcsum="$2"
	local csum

	csum="$(md5sum "$file" | cut -f1 -d' ')"
	if [ -z "$xcsum" -o "$xcsum" = "$csum" ]; then
		return 0
	else
		__errmsg "md5sum not match"
		__errmsg ""
		__errmsg "        file: $file"
		__errmsg "    expected: $xcsum"
		__errmsg "      actual: $csum"
		return 1
	fi
}

download_http() {
	local file="$BASE_DL_DIR/$1"
	local url="$2"
	local csum="$3"
	local tmp="$file.dl"

	# expecting set -e will abort if anything bad happens
	if [ -f "$file" ]; then
		if _csum_check "$file" "$csum"; then
			return 0
		else
			return 1
		fi
	fi
	wget -c -O "$tmp" "$url"
	mv "$tmp" "$file"
	_csum_check "$file" "$csum"
}

download_extra() {
	true
}

download() {
	download_http "$PKG_SOURCE" "$PKG_SOURCE_URL" "$PKG_SOURCE_MD5SUM"
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

compile() {
	cd "$PKG_BUILD_DIR"
	eval CFLAGS="'$EXTRA_CFLAGS'" \
		CPPFLAGS="'$EXTRA_CPPFLAGS'" \
		LDFLAGS="'$EXTRA_LDFLAGS'" \
		make -j "$NJOBS" "$MAKE_VARS" ${PKG_CMAKE:+VERBOSE=1}
}

configure_pre() {
	true
}

configure() {
	if [ -n "$PKG_CMAKE" ]; then
		build_configure_cmake
	else
		build_configure_default
	fi
}

staging_pre() {
	rm -rf "$PKG_STAGING_DIR"
}

staging() {
	cd "$PKG_BUILD_DIR"
	eval "$MAKE_VARS" \
		make -j "$NJOBS" install DESTDIR="$PKG_STAGING_DIR" ${PKG_CMAKE:+VERBOSE=1} "$MAKE_VARS"
}

install_pre() {
	# 1. Find the non-wriable ones in staging dir
	# 2. rm -rf them in install_prefix before the installation
	# find dest_dir/openssl-1.0.2e-install/home/yousong/.usr -not -perm -0200
	true
}

install() {
	mkdir -p "$INSTALL_PREFIX"
	cp "$PKG_STAGING_DIR/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

install_post() {
	true
}

archive() {
	true
}

clean() {
	rm -rf "$PKG_BUILD_DIR"
}

uninstall() {
	local sf tf
	local dir="$PKG_STAGING_DIR/$INSTALL_PREFIX"

	for sf in $(find "$dir" -mindepth 1); do
		tf="${sf#$dir/}"
		tf="$INSTALL_PREFIX/$tf"
		if [ -f "$tf" ]; then
			rm -vf $tf
		elif [ -d "$tf" ]; then
			rmdir -v --parents --ignore-fail-on-non-empty "$tf"
		fi
	done
}

till() {
	local p="$1"
	local a
	local phases='
		download
		prepare
		configure_pre
		configure
		compile
		staging_pre
		staging
		install_pre
		install
		install_post
	'

	for a in $phases; do
		$a
		if [ "$a" = "$p" ]; then
			return 0
		fi
	done
}

if [ "$#" -eq 0 ]; then
	set -- till _end
fi
trap "$*" EXIT
