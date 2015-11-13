#!/bin/sh -e

PKGNAME=nginx

. "$PWD/env.sh"
# where to put source code
MODPATH="$BASE_DL_DIR"

_ngx_clone_or_pull() {
    local url="$1"
    local p="$2"

    # extract repo dir from repo url.
    [ -z "$p" ] && {
        p="$url"
        p=${p##*/}
        p=${p%.git}
    }

    if [ -d "$p/.git" ]; then
        (    cd "$p"; 
             git pull;
        )
    else
        git clone "$url" "$p"
    fi
}

# what modules to pull
ngx_initialize_repo() {
    local i mods

	mkdir -p "$MODPATH" || {
		__errmsg "Failed creating $MODPATH."
		return 1
	}
    cd "$MODPATH"

    _ngx_clone_or_pull https://github.com/nginx/nginx.git

    _ngx_clone_or_pull https://github.com/chaoslawful/lua-nginx-module.git  nginx-lua
    _ngx_clone_or_pull https://github.com/simpl/ngx_devel_kit.git nginx-devel-kit

    mods="array-var-nginx-module
        dns-nginx-module
        echo-nginx-module
        headers-more-nginx-module
        memc-nginx-module
        rds-csv-nginx-module
        rds-json-nginx-module
        redis2-nginx-module
        set-misc-nginx-module
        xss-nginx-module"
    for i in $mods; do
        _ngx_clone_or_pull https://github.com/agentzh/$i.git nginx-${i%-nginx*}
    done
}

ngx_build_vanilla() {
	local dest_dir="$BASE_DESTDIR/_$PKGNAME-install"

	# NGINX does not support out of tree build.
    cd "$MODPATH/nginx"

    # This will build vanilla NGINX with nginx-lua depending on LuaJIT, LuaJIT
    # has to be preinstalled.
    #LUAJIT_LIB=/opt/local/lib                        \
    #LUAJIT_INC=/opt/local/include/luajit-2.0         \
    ./configure --prefix="$INSTALL_PREFIX"           \
        --sbin-path=nginx                            \
        --conf-path=nginx.conf                       \
        --pid-path=nginx.pid                         \
        --error-log-path=error.log                   \
        --http-log-path=access.log                   \
        --with-http_ssl_module                       \
        --with-http_mp4_module                       \
        --add-module=$MODPATH/nginx-devel-kit        \
        --add-module=$MODPATH/nginx-echo             \
        --add-module=$MODPATH/nginx-set-misc         \
        --add-module=$MODPATH/nginx-lua              \
        --add-module=$MODPATH/nginx-array-var        \
        --add-module=$MODPATH/nginx-headers-more  && \
    make -j"$NJOB"                                && \
	rm -rf "$dest_dir"
    make DESTDIR="$dest_dir" install
	# vanilla nginx is for playing, don't install it.
    #ls "$dest_dir/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}


#ngx_initialize_repo
#ngx_build_vanilla
