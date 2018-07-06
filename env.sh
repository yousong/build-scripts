#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
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

METADATA_DIR="${METADATA_DIR:-$INSTALL_PREFIX/.build-scripts-metadata}"

o_dl_cmd="${o_dl_cmd:-wget}"
o_dl_jobs="${o_dl_jobs:-16}"


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

cpdir() {
	cp -f -a -T "$@"
}

env_init() {
	mkdir -p "$BASE_DL_DIR"
	mkdir -p "$BASE_BUILD_DIR"
	mkdir -p "$BASE_DESTDIR"
	mkdir -p "$INSTALL_PREFIX"
	mkdir -p "$METADATA_DIR"

	STRIP=( strip --strip-all )
	PKG_CONFIG_PATH="$INSTALL_PREFIX/lib/pkgconfig:$INSTALL_PREFIX/share/pkgconfig"
	EXTRA_CPPFLAGS+=( -isystem "$INSTALL_PREFIX/include" )
	EXTRA_CFLAGS+=( -isystem "$INSTALL_PREFIX/include" )
	EXTRA_LDFLAGS+=( -L"$INSTALL_PREFIX/lib" -Wl,-rpath,"$INSTALL_PREFIX/lib" )
	if [ -d "$INSTALL_PREFIX/lib64" ]; then
		PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$INSTALL_PREFIX/lib64/pkgconfig"
		EXTRA_LDFLAGS+=( -L"$INSTALL_PREFIX/lib64" -Wl,-rpath,"$INSTALL_PREFIX/lib64")
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
		EXTRA_CPPFLAGS+=( -isystem "$MACPORTS_PREFIX/include")
		EXTRA_CFLAGS+=( -isystem "$MACPORTS_PREFIX/include")
		EXTRA_LDFLAGS+=( -L"$MACPORTS_PREFIX/lib" -Wl,-rpath,"$MACPORTS_PREFIX/lib")
	fi
	EXTRA_CXXFLAGS+=( ${EXTRA_CFLAGS[@]} )
	export PKG_CONFIG_PATH
	if ! running_in_make || [ -n "$NJOBS" ]; then
		NJOBS="${NJOBS:-$((2 * $(ncpus)))}"
		MAKEJ=(make -j "$NJOBS")
	else
		MAKEJ=(make)
	fi
}

env_check() {
	local d
	local dusergroup
	local usergroup="$(id -u --name):"$(id -g --name)""

	for d in var/log var/run; do
		d="$INSTALL_PREFIX/$d"
		[ -d "$d" ] || continue
		dusergroup="$(stat --format=%U:%G "$d")"
		if [ "$dusergroup" != "$usergroup" ]; then
			__errmsg "directory $d is owned by $dusergroup, expecting: chown $usergroup $d"
		fi
	done
}

env_init_pkg() {
	local proto
	local dirbn

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
		dirbn="${PKG_BUILD_DIR_BASENAME:-${PKG_SOURCE%.tar.gz}}"
		PKG_SOURCE_DIR="$BASE_BUILD_DIR/$dirbn"
		PKG_STAGING_DIR="$BASE_DESTDIR/$dirbn-install"
	else
		if [ -n "$PKG_BUILD_DIR_BASENAME" ]; then
			PKG_SOURCE_DIR="$BASE_BUILD_DIR/$PKG_BUILD_DIR_BASENAME"
		else
			PKG_SOURCE_DIR="$BASE_BUILD_DIR/$(unpack_dirname "$PKG_SOURCE")"
		fi
		PKG_STAGING_DIR="$BASE_DESTDIR/$PKG_NAME-$PKG_VERSION-install"
	fi
	if [ -n "$PKG_CMAKE" ]; then
		if [ -z "$PKG_CMAKE_BUILD_SUBDIR" ]; then
			PKG_CMAKE_BUILD_SUBDIR=build
		fi
		PKG_BUILD_DIR="$PKG_SOURCE_DIR/$PKG_CMAKE_BUILD_SUBDIR"
	else
		PKG_BUILD_DIR="$PKG_SOURCE_DIR"
	fi

	PKG_METADATA_DIR="$METADATA_DIR/$PKG_NAME-$PKG_VERSION"

	CONFIGURE_PATH="${CONFIGURE_PATH:-$PKG_BUILD_DIR}"
	CONFIGURE_CMD="${CONFIGURE_CMD:-$PKG_SOURCE_DIR/configure}"
	CONFIGURE_ARGS+=(
		--prefix="$INSTALL_PREFIX"
	)
	env_init_pkg_afl_
}

env_init_pkg_afl_() {
	local afl_cc afl_cxx

	if [ -z "$ENABLE_AFL_FUZZ" -o "$ENABLE_AFL_FUZZ" = 0 ]; then
		return 0
	fi

	afl_cc="$(which afl-gcc)"
	if [ -z "$afl_cc" ]; then
		__errmsg "cannot find afl-gcc"
		return 1
	fi

	afl_cxx="$(which afl-g++)"
	if [ -z "$afl_cc" ]; then
		__errmsg "cannot find afl-g++"
		return 1
	fi

	CONFIGURE_VARS+=(
		CC="$afl_cc"
		CXX="$afl_cxx"
	)
	# AFL_HARDEN will enable gcc option -fstack-protector-all
	#
	# Check getenv() call in afl source code for more knobs in the environment
	MAKE_ENVS+=(
		AFL_HARDEN=1
	)
	MAKE_ARGS+=(
		CC="$afl_cc"
		CXX="$afl_cxx"
	)
}

env_init_gnu_toolchain() {
	. $PWD/utils-toolchain.sh

	if ! [ -x "$GNU_TOOLCHAIN_CC" -a -x "$GNU_TOOLCHAIN_CXX" ]; then
		__errmsg "cannot find executable $GNU_TOOLCHAIN_CC, or $GNU_TOOLCHAIN_CXX"
		return 1
	fi
	EXTRA_LDFLAGS+=( -Wl,--dynamic-linker="$GNU_TOOLCHAIN_DIR_LIB/ld-linux-x86-64.so.2" )
	EXTRA_LDFLAGS+=( -Wl,-rpath,"$GNU_TOOLCHAIN_DIR_LIB" -L"$GNU_TOOLCHAIN_DIR_LIB" )

	CONFIGURE_VARS+=(
		CC="$GNU_TOOLCHAIN_CC"
		GCC="$GNU_TOOLCHAIN_CC"
		CXX="$GNU_TOOLCHAIN_CXX"
		LD="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ld"
		AS="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-as"
		AR="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ar"
		NM="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-nm"
		RANLIB="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ranlib"
		STRIP="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-strip"
		OBJCOPY="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-objcopy"
		OBJDUMP="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-objdump"
		SIZE="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-size"
	)
	MAKE_VARS+=(
		CC="$GNU_TOOLCHAIN_CC"
		GCC="$GNU_TOOLCHAIN_CC"
		CXX="$GNU_TOOLCHAIN_CXX"
		LD="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ld"
		AS="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-as"
		AR="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ar"
		NM="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-nm"
		RANLIB="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-ranlib"
		STRIP="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-strip"
		OBJCOPY="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-objcopy"
		OBJDUMP="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-objdump"
		SIZE="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-size"
	)
	CMAKE_ARGS+=(
		-DCMAKE_C_COMPILER="$GNU_TOOLCHAIN_CC"
		-DCMAKE_CXX_COMPILER="$GNU_TOOLCHAIN_CXX"
	)
}

# Some build systems passes $EXTRA_LDFLAGS directly to the linker, but
# -Wl,-rpath,xxx is for the compiler
env_fixup_extra_ldflags() {
	local idx val

	for idx in "${!EXTRA_LDFLAGS[@]}"; do
		val="${EXTRA_LDFLAGS[$idx]}"
		EXTRA_LDFLAGS[$idx]="${val/-Wl,-rpath,/-rpath=}"
	done
}

env_csum_check() {
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
	local source="$1"
	local path="$BASE_DL_DIR/$source"
	local url="$2"
	local csum="$3"

	# expecting set -e will abort if anything bad happens
	if [ -f "$path" ]; then
		if env_csum_check "$path" "$csum"; then
			return 0
		else
			return 1
		fi
	fi

	download_http_with_mirrors "$source" "$url"
	env_csum_check "$path" "$csum"
}

download_http_with_mirrors() {
	local source="$1"; shift
	local url="$1"; shift
	local path="$BASE_DL_DIR/$source"
	local tmp="$path.dl"
	local mirrors="
		http://sources.openwrt.org
		http://distfiles.gentoo.org/distfiles
		https://fossies.org/linux/misc
	"
	local mirror

	if "download_cmd_$o_dl_cmd" "$tmp" "$url"; then
		mv "$tmp" "$path"
		return 0
	else
		for mirror in $mirrors; do
			rm -vf "$tmp"
			if "download_cmd_$o_dl_cmd" "$tmp" "$mirror/$source"; then
				mv "$tmp" "$path"
				return 0
			fi
		done
	fi
	return 1
}

download_cmd_mget() {
	local output="$1"; shift
	local url="$1"; shift

	mget --output "$output" --url "$url" --count "$o_dl_jobs"
}

download_cmd_wget() {
	local output="$1"; shift
	local url="$1"; shift

	wget -c -O "$output" "$url"
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

unpack_dirname() {
	local fn="$1"

	fn="${fn%%.tar*}"
	fn="${fn%%.tgz}"
	fn="${fn%%.tbz2}"
	fn="${fn%%.zip}"
	echo "$fn"
}

unpack() {
	local file="$1"
	local dir="$2"
	local trans_exp="$3"
	local fn="$(basename $file)"
	local opt_ftyp opts
	local ftyp

	# The following options are only supported by GNU tar.
	#
	#	--transform
	#	--gzip (-z)
	#	--bzip2 (-j)
	#	--xz (-J)
	#
	# The MacPorts package name is gnutar
	ftyp=tar
	case "$fn" in
		*.tar.gz|*.tgz)
			opt_ftyp="--gzip"
			;;
		*.tar.bz2)
			opt_ftyp="--bzip2"
			;;
		*.tar.xz)
			opt_ftyp="--xz"
			;;
		*.zip)
			ftyp="zip"
			;;
		*)
			__errmsg "unknown file type: $file"
			return 1
			;;
	esac

	if [ "$ftyp" = tar ]; then
		[ -z "$dir" ] || opts="$opts -C $dir"
		# search transform_flags in tar source code
		#
		#  - r, R, regular file
		#  - h, H, hard link
		#  - s, S, symbolic link
		#
		# defaults to rhs; r=rhsHS
		[ -z "$trans_exp" ] || opts="$opts --transform=flags=r;$trans_exp"
		tar $opts $opt_ftyp -xf "$file"
	elif [ "$ftyp" = zip ]; then
		( cd "$dir" && unzip "$file"; )
	else
		# unreachable
		return 1
	fi
}

prepare_source() {
	local dir
	local trans_exp

	if [ -n "$PKG_SOURCE_UNTAR_FIXUP" ]; then
		dir="$(basename $PKG_SOURCE_DIR)"
		trans_exp="s:^[^/]\\+:$dir:"
	fi
	unpack "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR" "$trans_exp"
}

prepare_extra() {
	true
}

do_patch() {
	true
}

prepare() {
	if [ -d "$PKG_SOURCE_DIR" ]; then
		__errmsg "$PKG_SOURCE_DIR already exists, skip preparing."
	else
		prepare_source
		prepare_extra
		do_patch
	fi
}

build_configure_default() {
	mkdir -p "$CONFIGURE_PATH"
	cd "$CONFIGURE_PATH"
	env	CPPFLAGS="${EXTRA_CPPFLAGS[*]}"	\
		CFLAGS="${EXTRA_CFLAGS[*]}"		\
		CXXFLAGS="${EXTRA_CXXFLAGS[*]}"	\
		LDFLAGS="${EXTRA_LDFLAGS[*]}"	\
		"${CONFIGURE_VARS[@]}"			\
		"$CONFIGURE_CMD"				\
		"${CONFIGURE_ARGS[@]}"
}

build_configure_cmake() {
	mkdir -p "$PKG_BUILD_DIR"
	cd "$PKG_BUILD_DIR"
	env "${CMAKE_ENVS[@]}"									\
		cmake												\
		-DCMAKE_BUILD_TYPE=Release							\
		-DCMAKE_PREFIX_PATH="$INSTALL_PREFIX"				\
		-DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"			\
		-DCMAKE_EXE_LINKER_FLAGS="${EXTRA_LDFLAGS[*]}"		\
		-DCMAKE_SHARED_LINKER_FLAGS="${EXTRA_LDFLAGS[*]}"	\
		-DCMAKE_C_FLAGS="${EXTRA_CFLAGS[*]}"				\
		-DCMAKE_CXX_FLAGS="${EXTRA_CXXFLAGS[*]}"			\
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=on					\
		-DCMAKE_MACOSX_RPATH=on								\
		"${CMAKE_ARGS[@]}"									\
		"$PKG_SOURCE_DIR/$PKG_CMAKE_SOURCE_SUBDIR"
}

build_compile_make() {
	cd "$PKG_BUILD_DIR"
	env CFLAGS="${EXTRA_CFLAGS[*]}"			\
		CXXFLAGS="${EXTRA_CXXFLAGS[*]}"		\
		CPPFLAGS="${EXTRA_CPPFLAGS[*]}"		\
		LDFLAGS="${EXTRA_LDFLAGS[*]}"		\
		"${MAKE_ENVS[@]}"					\
		"${MAKEJ[@]}"								\
			"${MAKE_ARGS[@]}"				\
			${PKG_CMAKE:+VERBOSE=1}			\
			"${MAKE_VARS[@]}"				\
			"$@"
}

compile() {
	build_compile_make
}

autoconf_fixup() {
	# cd to the right directory before calling me
	#
	# --force, consider all files obsolete
	# --install, copy missing auxiliary files
	autoreconf --verbose --force --install
}

configure_pre() {
	if [ -n "$PKG_AUTOCONF_FIXUP" ]; then
		cd "$PKG_SOURCE_DIR"
		autoconf_fixup
	fi
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

build_staging() {
	cd "$PKG_BUILD_DIR"
	env "${MAKE_ENVS[@]}"				\
		"${MAKEJ[@]}"							\
			"${MAKE_ARGS[@]}"			\
			DESTDIR="$PKG_STAGING_DIR"	\
			${PKG_CMAKE:+VERBOSE=1}		\
			"${MAKE_VARS[@]}"			\
			"$@"
}

staging_check_default() {
	local nsubdir

	nsubdir="$(ls "$PKG_STAGING_DIR" | wc -l )"
	if [ "$nsubdir" -ge 2 ]; then
		__errmsg "$PKG_STAGING_DIR has $nsubdir subdirs"
		return 1
	fi
}

staging() {
	build_staging 'install'
}

staging_post_strip() {
	local d="$1"
	local f t

	# strip is binary format dependent: elf, mach-o, x86_64, x86, powerpc, etc.
	if [ "${#STRIP[@]}" -eq 0 ]; then
		return 0
	fi
	find "$d" -type f -a -not -name '*.ko' -exec file {} \; | \
		sed -n -e 's/^\(.*\):.*ELF.*\(executable\|relocatable\|shared object\).*,.* stripped/\1 \2/p' | \
			while read f t; do
				if [ -w "$f" ]; then
					"${STRIP[@]}" "$f"
				fi
			done
}

staging_post() {
	if [ -d "$PKG_STAGING_DIR" ]; then
		staging_check_default
		staging_post_strip "$PKG_STAGING_DIR$INSTALL_PREFIX"
	fi
}

install_pre() {
	# 1. Find the non-wriable ones in staging dir
	# 2. rm -rf them in install_prefix before the installation
	# find dest_dir/openssl-1.0.2e-install/home/yousong/.usr -not -perm -0200
	true
}

install() {
	mkdir -p "$INSTALL_PREFIX"
	cpdir "$PKG_STAGING_DIR$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

install_post() {
	true
}

archive() {
	metadata_gen_listing
}

metadata_gen_listing() {
	mkdir -p "$PKG_METADATA_DIR"
	uninstall_gen_listing "$PKG_STAGING_DIR/$INSTALL_PREFIX" >"$PKG_METADATA_DIR/listing"
}

clean_extra() {
	true
}

clean() {
	rm -rf "$PKG_BUILD_DIR"
	if [ "$PKG_SOURCE_DIR" != "$PKG_BUILD_DIR" ]; then
		rm -rf "$PKG_SOURCE_DIR"
	fi
	clean_extra
}

uninstall_gen_listing() {
	local one="$1"
	local sf tf

	# $one should not end with slash
	for sf in $(find "$one" -mindepth 1 -depth); do
		tf="${sf#$one/}"
		echo "$tf"
	done
}

uninstall_from_listing() {
	local another="$1"
	local tf
	local r=0

	while read tf; do
		tf="$another/$tf"
		# remove regular file and symbolic link
		if [ -f "$tf" -o -L "$tf" ]; then
			rm -vf $tf
		elif [ -d "$tf" ]; then
			rmdir -v --parents --ignore-fail-on-non-empty "$tf"
		elif [ -e "$tf" ]; then
			__errmsg "what is this: $tf"
			r=1
		fi
	done
}

uninstall_one_from_another() {
	local one="$1"
	local another="$2"

	uninstall_gen_listing "$one" \
		| uninstall_from_listing "$another"
}

uninstall() {
	local one="$PKG_STAGING_DIR/$INSTALL_PREFIX"
	local another="$INSTALL_PREFIX"

	if [ ! -f "$PKG_METADATA_DIR/listing" -a -d "$one" ]; then
		metadata_gen_listing
	fi
	uninstall_from_listing "$another" <"$PKG_METADATA_DIR/listing"
	rm -rf "$PKG_METADATA_DIR"
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

genmake_stampdir() {
	echo "\$(STAMP_DIR)"
}

genmake_logdir() {
	echo "\$(LOG_DIR)"
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
		install:install_pre#install#install_post:archive
	'
	local stampdir="$(genmake_stampdir)"
	local logdir="$(genmake_logdir)"

	for d in $dep_desc; do
		local phasel="${d%%:*}"
		local phaser="${d##*:}"
		local stampl="$stampdir/stamp.$PKG_NAME.$phasel"
		local stampr="$stampdir/stamp.$PKG_NAME.$phaser"
		local logl="$logdir/log.$PKG_NAME.$phasel"
		local action actions

		cat <<EOF
\$(eval \$(call rule_mkdir,$stampdir))
\$(eval \$(call rule_mkdir,$logdir))
$stampl: | $stampdir $logdir
	@+$PKG_SCRIPT_NAME platform_check >$logl 2>&1 || \\
		{ touch "$stampdir/stamp.$PKG_NAME.skipped"; exit 0; }; \\
EOF
		actions="${d#*:}"
		actions="${actions%:*}"
		actions="$(echo $actions | tr '#' ' ')"
		cat <<EOF
	for action in $actions; do \\
		echo "${PKG_SCRIPT_NAME##*/} \$\$action"; \\
		$PKG_SCRIPT_NAME \$\$action >>$logl 2>&1 || \\
			{ echo "${PKG_SCRIPT_NAME##*/} \$\$action failed;  see $logl for details"; exit 1; }; \\
	done
EOF

		cat <<EOF
	@touch $stampl
$PKG_NAME/$phasel: $stampl
.PHONY: $PKG_NAME/$phasel
$phasel: $stampl

EOF
		if [ -n "$phaser" ]; then
			cat <<EOF
$stampl: $stampr

EOF
		fi
	done

	for d in $PKG_DEPENDS; do
		mdepends="$stampdir/stamp.${d}.install $mdepends"
	done
	mdepends="${mdepends% }"

	# TODO: track utils-.sh
	cat <<EOF
$PKG_SCRIPT_NAME: $TOPDIR/env.sh
	@[ -x "$PKG_SCRIPT_NAME" ] && touch "$PKG_SCRIPT_NAME"

$stampdir/stamp.$PKG_NAME.download: $PKG_SCRIPT_NAME
$stampdir/stamp.$PKG_NAME.configure: $mdepends
$PKG_NAME/clean:
	$PKG_SCRIPT_NAME clean
	rm -v $stampdir/stamp.$PKG_NAME.* || true

$PKG_NAME/uninstall:
	$PKG_SCRIPT_NAME uninstall

.PHONY: $PKG_NAME/clean
.PHONY: $PKG_NAME/uninstall
EOF
}

o_phases='
	download
	prepare
	configure_pre
	configure
	compile
	staging_pre
	staging
	staging_post
	archive
	install_pre
	install
	install_post
'

from_to() {
	local from="${1%%:*}"
	local to="${1##*:}"
	local in_range=

	[ -n "$from" ] || from=download
	[ -n "$to" ] || to=install_post

	set -- $o_phases
	while [ "$#" -gt 0 ]; do
		if [ -z "$in_range" ]; then
			if [ "$1" = "$from" ]; then
				in_range=1
				"$1"
			fi
		else
			"$1"
		fi
		if [ "$1" = "$to" ]; then
			break
		fi
		shift
	done
}

from() {
	local from="$1"; shift
	from_to "$from:"
}

to() {
	local to="$1"; shift
	from_to ":$to"
}

env_check
env_init
env_init_pkg
if [ "$#" -eq 0 ]; then
	set -- to _end
fi
trap "$*" EXIT
