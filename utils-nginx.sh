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

nginx_get_mod_info() {
	local what="$1"
	local desc="$2"
	local oIFS
	local ref repo subdir
	local fn source source_url

	oIFS="$IFS"; IFS=:; set -- $desc; IFS="$oIFS"
	ref="$1"
	repo="$2"
	subdir="$3"

	fn="${repo#*/}-$ref"
	source="$fn.tar.gz"
	source_url="https://github.com/$repo/archive/$ref.tar.gz"

	case "$what" in
		source)
			echo "$source"
			;;
		source_url)
			echo "$source_url"
			;;
		fn)
			echo "$fn"
			;;
		mod_dir)
			echo "$NGINX_MODS_DIR/$fn${subdir:+/$subdir}"
			;;
		*)
			__errmsg "unknown what to provide: $what"
			return 1
			;;
	esac
}

download_extra() {
	local m
	local fn source source_url

	for m in $MODS; do
		source="$(nginx_get_mod_info source "$m")"
		source_url="$(nginx_get_mod_info source_url "$m")"

		download_http "$source" "$source_url"
	done
}

prepare_extra() {
	local m
	local fn tarball

	mkdir -p "$NGINX_MODS_DIR"
	for m in $MODS; do
		fn="$(nginx_get_mod_info fn "$m")"
		source="$(nginx_get_mod_info source "$m")"
		tarball="$BASE_DL_DIR/$source"

		untar "$tarball" "$NGINX_MODS_DIR" "s:^[^/]\\+:$fn:"
	done
}

nginx_add_modules() {
	local m
	local mod_dir
	local arg

	for m in $MODS; do
		mod_dir="$(nginx_get_mod_info mod_dir "$m")"
		arg="	--add-module=$mod_dir"
		CONFIGURE_ARGS="${CONFIGURE_ARGS}${arg}"
	done
}
