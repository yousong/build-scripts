#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
NGINX_PREFIX="$INSTALL_PREFIX/nginx/$PKG_NAME-$PKG_VERSION"
NGINX_MODS_DIR="$PKG_BUILD_DIR/_mods"
CONFIGURE_ARGS="					\\
	--prefix="$NGINX_PREFIX"		\\
	--sbin-path=nginx				\\
	--conf-path=nginx.conf			\\
	--pid-path=nginx.pid			\\
	--error-log-path=error.log		\\
	--http-log-path=access.log		\\
	--with-cc-opt='$EXTRA_CFLAGS'	\\
	--with-ld-opt='$EXTRA_LDFLAGS'	\\
"

download_extra() {
	local m
	local fn source source_url

	for m in $MODS; do
		fn="$(nginx_get_mod_dirname "$m")"
		source="$fn.tar.gz"
		source_url="$(nginx_get_mod_source_url "$m")"

		download_http "$source" "$source_url"
	done
}

nginx_get_mod_dirname() {
	local desc="$1"
	local ref="${desc%:*}"
	local repo="${desc#*:}"
	local fn="${repo#*/}-$ref"

	echo "$fn"
}

nginx_get_mod_source_url() {
	local desc="$1"
	local ref="${desc%:*}"
	local repo="${desc#*:}"
	local fn="${repo#*/}-$ref"
	local source_url="https://github.com/$repo/archive/$ref.tar.gz"

	echo "$source_url"
}

prepare_extra() {
	local m
	local fn tarball

	mkdir -p "$NGINX_MODS_DIR"
	for m in $MODS; do
		fn="$(nginx_get_mod_dirname "$m")"
		tarball="$BASE_DL_DIR/$fn.tar.gz"

		untar "$tarball" "$NGINX_MODS_DIR" "s:^[^/]\\+:$fn:"
	done
}

nginx_add_modules() {
	local m
	local fn
	local arg

	for m in $MODS; do
		fn="$(nginx_get_mod_dirname "$m")"
		arg="	--add-module=$NGINX_MODS_DIR/$fn"
		CONFIGURE_ARGS="${CONFIGURE_ARGS}${arg}"
	done
}
