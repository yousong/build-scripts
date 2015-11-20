NGINX_MODS_DIR="$PKG_BUILD_DIR/_mods"

download_extra() {
	local m
	local ref repo
	local fn source source_url

	for m in $MODS; do
		ref="${m%:*}"
		repo="${m#*:}"
		fn="${repo#*/}-$ref"
		source="$BASE_DL_DIR/$fn.tar.gz"
		source_url="https://github.com/$repo/archive/$ref.tar.gz"

		if [ ! -s "$source" ]; then
			wget -c -O "$source.dl" "$source_url"
			mv "$source.dl" "$source"
		fi
	done
}

prepare_extra() {
	local m
	local ref repo
	local fn source

	mkdir -p "$NGINX_MODS_DIR"
	for m in $MODS; do
		ref="${m%:*}"
		repo="${m#*:}"
		fn="${repo#*/}-$ref"
		source="$BASE_DL_DIR/$fn.tar.gz"

		untar "$source" "$NGINX_MODS_DIR" "s:^[^/]\\+:$fn:"
	done
}

nginx_add_modules() {
	local m
	local ref repo
	local fn source
	local arg

	for m in $MODS; do
		ref="${m%:*}"
		repo="${m#*:}"
		fn="${repo#*/}-$ref"

		arg="	--add-module=$NGINX_MODS_DIR/$fn"
		CONFIGURE_ARGS="${CONFIGURE_ARGS}${arg}"
	done
}
