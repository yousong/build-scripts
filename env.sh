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
# where to put repos and files for Makefile
TMP_DIR="${TMP_DIR:-$TOPDIR/tmp}"
# where to put stamp files for Makefile
STAMP_DIR="${STAMP_DIR:-$TMP_DIR/stamp}"
# where to put log files when building with Makefile
LOG_DIR="${LOG_DIR:-$TMP_DIR/log}"


__errmsg() {
	echo "$1" >&2
}

os_is_darwin() {
	[ "$(uname -s)" = "Darwin" ]
}

os_is_linux() {
	[ "$(uname -s)" = "Linux" ]
}

running_in_make() {
	[ "${MAKEFLAGS-unset}" != unset ]
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
		#
		# OpenResty uses first two numbers of "sw_vers -productVersion"
		MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion)"
		MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET%.*}"
		export MACOSX_DEPLOYMENT_TARGET
		MACPORTS_PREFIX="${MACPORTS_PREFIX:-/opt/local}"
		PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$MACPORTS_PREFIX/lib/pkgconfig"
		PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$MACPORTS_PREFIX/share/pkgconfig"
		EXTRA_CPPFLAGS="$EXTRA_CPPFLAGS -I$MACPORTS_PREFIX/include"
		EXTRA_CFLAGS="$EXTRA_CFLAGS -I$MACPORTS_PREFIX/include"
		EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L$MACPORTS_PREFIX/lib -Wl,-rpath,$MACPORTS_PREFIX/lib"
	fi
	export PKG_CONFIG_PATH
	if ! running_in_make || [ -n "$NJOBS" ]; then
		NJOBS="${NJOBS:-$((2 * $(ncpus)))}"
		MAKEJ="make -j $NJOBS"
	else
		MAKEJ=make
	fi
}
_init

_init_pkg() {
	local proto

	if [ -z "$PKG_SCRIPT_NAME" ]; then
		PKG_SCRIPT_NAME="$0"
	fi

	if [ -z "$PKG_SOURCE_PROTO" ]; then
		for proto in http https ftp git; do
			if [ "${PKG_SOURCE_URL#$proto://}" != "$PKG_SOURCE_URL" ]; then
				PKG_SOURCE_PROTO="$proto"
				break
			fi
		done
	fi
	if [ -z "$PKG_SOURCE_PROTO" ]; then
		__errmsg "unknown proto for PKG_SOURCE_URL: $PKG_SOURCE_URL"
		return 1
	fi
	if [ "$PKG_SOURCE_PROTO" = git ]; then
		PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
		PKG_BUILD_DIR="$BASE_BUILD_DIR/${PKG_SOURCE%.tar.gz}"
		PKG_STAGING_DIR="$BASE_DESTDIR/${PKG_SOURCE%.tar.gz}-install"
	else
		PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME-$PKG_VERSION"
		PKG_STAGING_DIR="$BASE_DESTDIR/$PKG_NAME-$PKG_VERSION-install"
	fi
}
_init_pkg

_csum_check() {
	local file="$1"
	local xcsum="$2"
	local csum

	if [ -z "$xcsum" ]; then
		return 0
	fi
	csum="$(md5sum "$file" | cut -f1 -d' ')"
	if [ "$xcsum" = "$csum" ]; then
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

download_git() {
	local name="$1"
	local url="$2"
	local commit="$3"
	local file="$4"

	if [ -f "$BASE_DL_DIR/$file" ]; then
		return 0
	fi

	mkdir -p "$TMP_DIR/repos" && cd "$TMP_DIR/repos"
	if [ ! -d "$name" ]; then
		git clone "$url" "$name" --recursive
	fi
	cd $name
	if [ "$(git cat-file -t "$commit" 2>/dev/null)" != commit ]; then
		git pull
	fi
	git archive --prefix="${file%.tar.gz}/" --output "$BASE_DL_DIR/$file" "$commit"
}

download_extra() {
	true
}

download() {
	case "$PKG_SOURCE_PROTO" in
		http|https|ftp)
			download_http "$PKG_SOURCE" "$PKG_SOURCE_URL" "$PKG_SOURCE_MD5SUM"
			;;
		git)
			download_git "$PKG_NAME" "$PKG_SOURCE_URL" "$PKG_SOURCE_VERSION" "$PKG_SOURCE"
			;;
		*)
			__errmsg "unknown PKG_SOURCE_PROTO: $PKG_SOURCE_PROTO"
			return 1
	esac
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
	local dir
	local trans_exp

	if [ -n "$PKG_SOURCE_UNTAR_FIXUP" ]; then
		dir="$(basename $PKG_BUILD_DIR)"
		trans_exp="s:^[^/]\\+:$dir:"
	fi
	untar "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR" "$trans_exp"
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
	CONFIGURE_PATH="${CONFIGURE_PATH:-$PKG_BUILD_DIR}"
	CONFIGURE_CMD="${CONFIGURE_CMD:-./configure}"

	cd "$CONFIGURE_PATH"
	eval CPPFLAGS="'$EXTRA_CPPFLAGS'"	\
		CFLAGS="'$EXTRA_CFLAGS'"		\
		LDFLAGS="'$EXTRA_LDFLAGS'"		\
		"$CONFIGURE_VARS"				\
		"$CONFIGURE_CMD"		\
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
	local envs="${MAKE_ENVS%\\*}"
	local vars="${MAKE_VARS%\\*}"
	local args="${MAKE_ARGS%\\*}"

	cd "$PKG_BUILD_DIR"
	eval CFLAGS="'$EXTRA_CFLAGS'" \
		CPPFLAGS="'$EXTRA_CPPFLAGS'" \
		LDFLAGS="'$EXTRA_LDFLAGS'" \
		"$envs" \
		$MAKEJ "$args" ${PKG_CMAKE:+VERBOSE=1} "$vars"
}

autoconf_fixup() {
	# cd to the right directory before calling me
	#
	# --force, consider all files obsolete
	# --install, copy missing auxiliary files
	autoreconf --verbose --force --install
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
	local envs="${MAKE_ENVS%\\*}"
	local vars="${MAKE_VARS%\\*}"

	cd "$PKG_BUILD_DIR"
	eval "$envs" $MAKEJ $MAKE_ARGS install DESTDIR="$PKG_STAGING_DIR" ${PKG_CMAKE:+VERBOSE=1} $vars
}

staging_post() {
	true
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

	for sf in $(find "$dir" -mindepth 1 -depth); do
		tf="${sf#$dir/}"
		tf="$INSTALL_PREFIX/$tf"
		# remove regular file and symbolic link
		if [ -f "$tf" -o -L "$tf" ]; then
			rm -vf $tf
		elif [ -d "$tf" ]; then
			rmdir -v --parents --ignore-fail-on-non-empty "$tf"
		fi
	done
}

platform_check() {
	local os curos="$(uname -s | tr A-Z a-z)"
	local dep

	if [ -n "$PKG_PLATFORM" ]; then
		# check if we should build this package on $curos
		for os in $PKG_PLATFORM no; do
			if [ "$os" = "$curos" ]; then
				break
			elif [ "$os" = no ]; then
				__errmsg "$PKG_NAME skipped on $curos"
				exit 1
			fi
		done
	fi

	for dep in $PKG_DEPENDS; do
		# the stamp is made when running_in_make
		if [ -f "$STAMP_DIR/stamp.$dep.skipped" ]; then
			__errmsg "Skipping $PKG_NAME since $dep was already skipped"
			exit 1
		fi
	done
}

genmake() {
	local d mdepends
	# description format: target:<actions#separated#by#HASH:prerequisite
	local dep_desc='
		download:download:
		prepare:prepare:download
		configure:configure_pre#configure:prepare
		compile:compile:configure
		staging:staging_pre#staging#staging_post:compile
		archive:archive:staging
		install:install_pre#install#install_post:staging
	'

	for d in $dep_desc; do
		local phasel="${d%%:*}"
		local phaser="${d##*:}"
		local action actions

		cat <<EOF
$STAMP_DIR/stamp.$PKG_NAME.$phasel: | $STAMP_DIR $LOG_DIR
	@+$PKG_SCRIPT_NAME platform_check >$LOG_DIR/log.$PKG_NAME.$phasel 2>&1 || \\
		{ touch "$STAMP_DIR/stamp.$PKG_NAME.skipped"; exit 0; }; \\
EOF
		actions="${d#*:}"
		actions="${actions%:*}"
		actions="$(echo $actions | tr '#' ' ')"
		cat <<EOF
	for action in $actions; do \\
		echo "${PKG_SCRIPT_NAME##*/} \$\$action"; \\
		$PKG_SCRIPT_NAME \$\$action >>$LOG_DIR/log.$PKG_NAME.$phasel 2>&1 || \\
			{ echo "${PKG_SCRIPT_NAME##*/} \$\$action failed;  see $LOG_DIR/log.$PKG_NAME.$phasel for details"; exit 1; }; \\
	done
EOF

		cat <<EOF
	@touch \$@
$PKG_NAME/$phasel: $STAMP_DIR/stamp.$PKG_NAME.$phasel
.PHONY: $PKG_NAME/$phasel
$phasel: $STAMP_DIR/stamp.$PKG_NAME.$phasel

EOF
		if [ -n "$phaser" ]; then
			cat <<EOF
$STAMP_DIR/stamp.$PKG_NAME.$phasel: $STAMP_DIR/stamp.$PKG_NAME.$phaser

EOF
		fi
	done

	for d in $PKG_DEPENDS; do
		mdepends="$STAMP_DIR/stamp.$d.install $mdepends"
	done
	mdepends="${mdepends% }"

	# TODO: track utils-.sh
	cat <<EOF
$PKG_SCRIPT_NAME: $TOPDIR/env.sh
	touch $PKG_SCRIPT_NAME
$STAMP_DIR/stamp.$PKG_NAME.download: $PKG_SCRIPT_NAME
$STAMP_DIR/stamp.$PKG_NAME.configure: $mdepends
$PKG_NAME/clean:
	$PKG_SCRIPT_NAME clean
	rm -v $STAMP_DIR/stamp.$PKG_NAME.* || true

$PKG_NAME/uninstall:
	$PKG_SCRIPT_NAME uninstall

.PHONY: $PKG_NAME/clean
.PHONY: $PKG_NAME/uninstall
EOF
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
		staging_post
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
