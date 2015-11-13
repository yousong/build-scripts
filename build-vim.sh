#!/bin/sh -e

# Vim on Debian Wheezy 7 has version 7.3.547 (Fetched with command "vim --version")
#
#       sudo apt-get build-dep vim-nox
#       sudo apt-get install gawk liblua5.2-dev libncurses5-dev
#
# Vim on CentOS 7 has version 7.4.160
#
#       sudo yum-builddep vim-enhanced
#       sudo yum install -y lua-devel ruby-devel
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

fetch_patches() {
	local ver="$PKG_VERSION"
	local baseurl="ftp://ftp.vim.org/pub/vim/patches/$PKG_VERSION"
	local num_patches
	local num_process
	local i

	mkdir -p "$PATCH_DIR"
	cd "$PATCH_DIR"

	if [ -s ".listing" ]; then
		num_patches="$(cat .listing | awk '{ print $9 }' | grep -F "$ver." | wc -l)"
		num_patches_0="$(ls | wc -l)"
		if [ "$num_patches" -eq "$num_patches_0" ]; then
			__errmsg "All fetched, skip fetching patches."
			return 0
		fi
	fi

	wget --no-remove-listing --spider "$baseurl/"
	num_patches="$(cat .listing | awk '{ print $9 }' | grep -F "$ver." | wc -l)"
	num_process="$(($num_patches / 100))"
	for i in $(seq 0 $num_process); do
		# Each wget fetches at most 100 patches.
		#  - There is mawk in Debian wheezy not supporting `[0-9]{2}',
		#    http://invisible-island.net/mawk/manpage/mawk.html#h3-3_-Regular-expressions
		cat .listing | \
			awk " \$9 ~ /$ver\.$i[0-9][0-9]/ { print \"$baseurl/\"\$9 } " | \
			wget --no-verbose -c -i - &
	done
	wait
}

apply_patches() {
    local f

    cd "$PKG_BUILD_DIR"

    [ -f ".patched" ] && {
        __errmsg "$PKG_BUILD_DIR/.patched exists, skip patching."
        return 0
    } || true

    for f in $(ls "$PATCH_DIR"); do
        patch -p0 -i "$PATCH_DIR/$f"
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

main
