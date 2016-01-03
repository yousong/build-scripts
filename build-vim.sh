#!/bin/sh -e

# Vim on Debian Wheezy 7 has version 7.3.547 (Fetched with command "vim --version")
#
#	sudo apt-get build-dep vim-nox
#	sudo apt-get install gawk liblua5.2-dev libncurses5-dev
#
# Vim on CentOS 7 has version 7.4.160
#
#	sudo yum-builddep vim-enhanced
#	# or use the following method if you are on CentOS 6.5
#	sudo yum install -y lua-devel ruby-devel python-devel ncurses-devel perl-devel perl-ExtUtils-Embed
#
# 7.3 is the release version.
# 547 is the number of applied patches provided by vim.org.
PKG_NAME=vim
PKG_VERSION="7.4"
PKG_SOURCE="vim-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="ftp://ftp.vim.org/pub/vim/unix/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="607e135c559be642f210094ad023dc65"

. "$PWD/env.sh"
VER_ND="$(echo $PKG_VERSION | tr -d .)"
PKG_BUILD_DIR="$BASE_BUILD_DIR/vim$VER_ND"
PATCH_DIR="$BASE_DL_DIR/vim$VER_ND-patches"

CONFIGURE_ARGS='				\
	--enable-fail-if-missing    \
	--enable-luainterp			\
	--enable-perlinterp			\
	--enable-pythoninterp		\
	--enable-rubyinterp			\
	--enable-cscope				\
	--enable-multibyte			\
	--with-features=big			\
'
if os_is_darwin; then
	CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
		--with-lua-prefix=$MACPORTS_PREFIX	\\
"
fi

patches_all_fetched() {
	if [ -s "MD5SUMS" ] && md5sum --status -c MD5SUMS; then
		return 0
	else
		return 1
	fi
}

fetch_patches() {
	local ver="$PKG_VERSION"
	local baseurl="ftp://ftp.vim.org/pub/vim/patches/$PKG_VERSION"
	local num_patches
	local num_process
	local i l

	mkdir -p "$PATCH_DIR"
	cd "$PATCH_DIR"

	if patches_all_fetched; then
		__errmsg "All fetched, skip fetching patches"
		return 0
	fi

	# delete MD5SUMS to check for new patches
	wget -c "$baseurl/MD5SUMS"
	num_patches="$(wc -l MD5SUMS | cut -f1 -d' ')"
	num_process="$(($num_patches / 100))"
	for i in $(seq 0 $num_process); do
		# Each wget fetches at most 100 patches.
		grep "$PKG_VERSION\\.$i[0-9]\\+$" MD5SUMS | \
			while read l; do echo "$l" | md5sum --status -c || echo "$baseurl/${l##* }"; done | \
			wget --no-verbose -c -i - &
	done
	wait

	if ! patches_all_fetched; then
		__errmsg "Some patches were missing"
		return 1
	fi
}

apply_patches() {
	local f

	cd "$PKG_BUILD_DIR"

	if [ -f ".patched" ]; then
		__errmsg "$PKG_BUILD_DIR/.patched exists, skip patching."
		return 0
	fi

	for f in $(ls "$PATCH_DIR/$PKG_VERSION."*); do
		__errmsg "applying patch $f"
		patch -p0 -i "$f"
		__errmsg
	done
	touch .patched
}

show_build_dep() {
	local pkg="$1"

	apt-cache showsrc "$pkg" | sed -e '/Build-Depends:/!d;s/Build-Depends: \| |\|,\|([^)]*),*\|\[[^]]*\]//g'
	apt-cache showsrc "$pkg" | sed -e '/Build-Depends-Indep:/!d;s/Build-Depends-Indep: \| |\|,\|([^)]*),*\|\[[^]]*\]//g'
}

remove_build_dep() {
	local build_dep_vim_nox="$(show_build_dep vim-nox)"

	sudo aptitude markauto $build_dep_vim_nox
	sudo apt-get autoremove
}

do_patch() {
	fetch_patches
	apply_patches
}

