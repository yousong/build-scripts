
TOPDIR="$PWD"
NJOBS=32

# where to put source code.
BASE_DL_DIR="$TOPDIR/dl"
# where to do the build.
BASE_BUILD_DIR="$TOPDIR/build_dir"
# where to stage the install
BASE_DESTDIR="$TOPDIR/dest_dir"
# where to install
INSTALL_PREFIX="$HOME/.usr"

__errmsg() {
    echo "$1" >&2
}

_init() {
    mkdir -p "$BASE_DL_DIR"
    mkdir -p "$BASE_BUILD_DIR"
    mkdir -p "$BASE_DESTDIR"
    mkdir -p "$INSTALL_PREFIX"

    alias cp="cp -a -T"
}
_init
