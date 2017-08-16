#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# These are static x86_64 binaries of docker community version.
#
# - https://docs.docker.com/engine/installation/linux/docker-ce/binaries/
# - https://docs.docker.com/engine/installation/linux/linux-postinstall/
#
# It seems that static binaries of docker does not have udev sync support
# because on the machine it was built there was no static library of udev sync.
#
# - Just in case... http://www.draconyx.net/articles/build-a-dynamically-linked-docker.html
#
PKG_NAME=docker
PKG_VERSION=17.06.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-ce.tgz"
PKG_SOURCE_URL="https://download.docker.com/linux/static/stable/x86_64/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ecc2f2d99b64b35d8ad478eafcc6f502
PKG_DEPENDS=linux
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure() {
	true
}

compile() {
	true
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"
	mkdir -p "$bindir"
	cpdir "$PKG_BUILD_DIR" "$bindir"
}

install_post() {
	cat >&2 <<EOF
Prepare user/group

	sudo groupadd --system docker
	sudo usermod --append --groups docker $USER

Mount cgroups fs on /sys/fs/cgroups/

	sudo apt-get install cgroups-mount
	sudo cgroups-mount

Run the daemon (docker-containerd, etc. need to be in PATH to be found by dockerd)

	sudo dockerd
	sudo dockerd --debug

	cat >daemon.json <<EOF
	{
		"registry-mirrors": [
			"https://docker.mirrors.ustc.edu.cn",
			"http://hub-mirror.c.163.com",
			"https://registry.docker-cn.com"
		],
		"live-restore": true
	}
	EOF
	sudo dockerd --config-file daemon.json

Test

	sudo docker run hello-world
EOF
}
