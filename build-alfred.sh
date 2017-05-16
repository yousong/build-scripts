#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# https://www.open-mesh.org/projects/alfred/wiki
# https://downloads.open-mesh.org/batman/manpages/alfred.8.html
# https://git.open-mesh.org/alfred.git/blob_plain/refs/heads/master:/README
#
# Examples
#
#	sudo ./alfred -i eth1 -b none -m
#	echo hello | sudo ./alfred -s 1001
#	sudo ./alfred -r 1001
#
# alfred uses ipv6 link-local multicast by default
#
PKG_NAME=alfred
PKG_VERSION=v2017.0
PKG_SOURCE_PROTO=git
PKG_SOURCE_VERSION=b8a8df5408c1052752ca3d72214482791fa681f6
PKG_SOURCE_URL=https://git.open-mesh.org/alfred.git
PKG_DEPENDS='libnl3'

. "$PWD/env.sh"

configure() {
	true
}

# Refer to README file in the source code for details about how to install and
# how to use
#
# - batadv-vis
# - alfred-gpsd, requires libgps
# - to drop unneeded capability requires libcap
#
MAKE_VARS="$MAKE_VARS				\\
	CONFIG_ALFRED_CAPABILITIES=n	\\
	CONFIG_ALFRED_GPSD=n			\\
	CONFIG_ALFRED_VIS=y				\\
"
