#!/bin/sh

if [ "$#" -gt 0 ]; then
	builders="$*"
else
	builders="$(ls build-*.sh)"
fi
tests_dir=$PWD/tests_dir
rm -rf "$tests_dir"
mkdir -p "$tests_dir"

export TOPDIR=$PWD
export INSTALL_PREFIX="$tests_dir/_install"
export BASE_BUILD_DIR="$tests_dir/_build_dir}"

mkdir -p "$INSTALL_PREFIX"

for b in $builders; do
	echo -n "working on $b: "
	sh -ex $b 1>"$tests_dir/${b}.log" 2>&1
	[ "$?" = 0 ] && echo "success" || echo "fail"
done
