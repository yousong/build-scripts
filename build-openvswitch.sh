#!/bin/sh -e

PKGNAME=openvswitch
VER="2.3.1"

. "$PWD/env.sh"
BUILD_DIR="$BASE_BUILD_DIR/openvswitch-$VER"

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
# 
#  - OVS repo version tags are prefixed with `v'.
#  - OVS repo tag v2.3 corresponds to release version 2.3.0
#  - OVS repo tag v2.0 corresponds to release version 2.0.0
#  - ...
#DIR_REPO="$HOME/devstack/git-repo/ovs"

__errmsg() {
    echo "$1" >&2
}

dirclean() {
    rm -rf "$BUILD_DIR"
}

prepare_from_tarball() {
    local ver="$1"
    local tar_dir="$BASE_BUILD_DIR/openvswitch-$ver"
    local fn="openvswitch-$ver.tar.gz"
    local url="http://openvswitch.org/releases/$fn"

    wget -c -O "$BASE_DL_DIR/$fn" "$url"
    tar -C "$BASE_BUILD_DIR" -xzf "$BASE_DL_DIR/$fn"
}

prepare_from_git() {
    local tag="v$1"

    cd "$DIR_REPO"
    mkdir -p "$BUILD_DIR"
    git archive --format=tar "$tag" | tar -C "$BUILD_DIR" -x
}

prepare_openvswitch() {
    [ -x "$BUILD_DIR/boot.sh" ] && {
        __errmsg "$BUILD_DIR/boot.sh already exists, skip preparing."
        __errmsg "    manually remove it to re-prepare it."
        return
    }

    if [ -d "$DIR_REPO/.git" ]; then
        prepare_from_git "$VER"
    else
        prepare_from_tarball "$VER"
    fi
}

build_openvswitch() {
	local dest_dir="$BASE_DESTDIR/_$PKGNAME-install"
	local kbuild_dir="/lib/modules/$(uname -r)/build"

    mkdir -p "$BUILD_DIR" || {
        __errmsg "Creating build dir "$BUILD_DIR" failed."
        return 1
    }

    cd "$BUILD_DIR"

	if [ ! -x "$BUILD_DIR/configure" ]; then
		__errmsg "Bootstrap a configure script."
		./boot.sh
	fi
    "$BUILD_DIR/configure"            \
        --prefix="$INSTALL_PREFIX"    \
        --with-linux="$kbuild_dir"    \
        --enable-ndebug               \

    make -j "$NJOBS"
	rm -rf "$dest_dir"
    make DESTDIR="$dest_dir" install
    #cp "$dest_dir/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

#dirclean
prepare_openvswitch
build_openvswitch
