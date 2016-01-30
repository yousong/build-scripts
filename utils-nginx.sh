NGINX_MODS_DIR="$PKG_BUILD_DIR/_mods"
CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
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
	local ref repo
	local fn source source_url

	for m in $MODS; do
		ref="${m%:*}"
		repo="${m#*:}"
		fn="${repo#*/}-$ref"
		source="$fn.tar.gz"
		source_url="https://github.com/$repo/archive/$ref.tar.gz"

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
