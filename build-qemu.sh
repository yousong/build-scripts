#!/bin/sh -e

PKGNAME=qemu
# N.B. prefix the version number with `v'
VER="v2.3.0"
# Others targets can be found in text for `--target-list` option from output of
# `./configure --help`
TARGETS="i386-softmmu mipsel-softmmu mips-softmmu arm-softmmu"

. "$PWD/env.sh"
BUILD_DIR="$BASE_BUILD_DIR/$PKGNAME-$VER"

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
DIR_REPO="qemu/"

__errmsg() {
    echo "$1" >&2
}

dirclean() {
    rm -rf "$BUILD_DIR"
}

prepare_from_tarball() {
    local ver="${1#v}"
    local tar_dir="$BASE_BUILD_DIR/qemu-$ver"
    local fn="qemu-$ver.tar.bz2"
    local url="http://wiki.qemu-project.org/download/$fn"

    # wiki.qemu-project.org does not support Range header.
    wget -c -O "$BASE_DL_DIR/$fn" "$url"
    tar -C "$BASE_BUILD_DIR" -xjf "$BASE_DL_DIR/$fn"
    rm -rf "$BUILD_DIR"
    mv -T "$tar_dir" "$BUILD_DIR"
}

prepare_from_git() {
    local tag="$1"

    cd "$DIR_REPO"
    mkdir -p "$BUILD_DIR"
    git archive --format=tar "$tag" | tar -C "$BUILD_DIR" -x
}

prepare_qemu() {
    [ -x "$BUILD_DIR/configure" ] && {
        __errmsg "$BUILD_DIR/configure already exists, skip preparing."
        __errmsg "    manually remove it to re-prepare it."
        return
    }

    if [ -d "$DIR_REPO/.git" ]; then
        prepare_from_git "$VER"
    else
        prepare_from_tarball "$VER"
    fi
}

build_qemu() {
	local dest_dir="$BASE_DESTDIR/_$PKGNAME-install"

    mkdir -p "$BUILD_DIR" || {
        __errmsg "Creating build dir "$BUILD_DIR" failed."
        return 1
    }

    cd "$BUILD_DIR"

    "$BUILD_DIR/configure"            \
        --prefix="$INSTALL_PREFIX"    \
        --target-list="$TARGETS"      \

    make -j "$NJOBS"
	rm -rf "$dest_dir"
    make DESTDIR="$dest_dir" install
    cp "$dest_dir/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

#dirclean
prepare_qemu
build_qemu
