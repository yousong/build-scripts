#!/bin/sh -e

# where to put source code
MODPATH="$PWD"
# where to install with --prefix
INSTALL_PREFIX="$MODPATH/_nginx-install"

_NJOB=8

__errmsg() {
    echo "$1" >&2
}

_ngx_build_mkdir() {
    mkdir -p "$MODPATH" || {
        __errmsg "Failed creating $MODPATH."
        return 1
    }

    mkdir -p "$INSTALL_PREFIX" || {
        __errmsg "Failed creating $INSTALL_PREFIX."
        return 1
    }
}

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

    cd -
}

ngx_build_vanilla() {
    _ngx_build_mkdir

    cd "$MODPATH/nginx"

    # This will build vanilla NGINX with nginx-lua depending on LuaJIT, LuaJIT
    # has to be preinstalled.
    LUAJIT_LIB=/opt/local/lib                        \
    LUAJIT_INC=/opt/local/include/luajit-2.0         \
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
    make -j"$_NJOB"                               && \
    make install                                  && \

    cd -
}


ngx_build_openresty() {
    local ver="${1:-1.7.7.2}"
    local fn="ngx_openresty-$ver.tar.gz"
    local dir="${fn%%.tar.gz}"
    local url="http://openresty.org/download/$fn"

    _ngx_build_mkdir

    # OpenResty is self-contained.
    wget -c "$url"                            && \
        [ -d "$dir" ] || tar xzf "$fn"        && \
        cd "$dir"                             && \
        ./configure --prefix="$INSTALL_PREFIX"   \
            --sbin-path=nginx                    \
            --conf-path=nginx.conf               \
            --pid-path=nginx.pid                 \
            --error-log-path=error.log           \
            --http-log-path=access.log        && \
        make -j"$_NJOB"                       && \
        make install                          && \

    cd -
}

ngx_build_tengine() {
    local ver="${1:-2.1.0}"
    local fn="tengine-$ver.tar.gz"
    local dir="${fn%%.tar.gz}"
    local url="http://tengine.taobao.org/download/$fn"

    _ngx_build_mkdir

    # Tengine is also mostly self-contained.
    wget -c "$url"                            && \
        [ -d "$dir" ] || tar xzf "$fn"        && \
        cd "$dir"                             && \
        ./configure --prefix="$INSTALL_PREFIX"   \
            --sbin-path=nginx                    \
            --conf-path=nginx.conf               \
            --pid-path=nginx.pid                 \
            --error-log-path=error.log           \
            --http-log-path=access.log        && \
        make -j"$_NJOB"                       && \
        make install                          && \

    cd -
}

#ngx_initialize_repo
#ngx_build_vanilla

#ngx_build_tengine
#ngx_build_openresty
