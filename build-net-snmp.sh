#!/bin/sh -e
#
PKG_NAME=net-snmp
PKG_VERSION=5.7.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://sourceforge.net/projects/net-snmp/files/net-snmp/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d4a3459e1577d0efa8d96ca70a885e53

. "$PWD/env.sh"

# --with-perl-modules accepts arguments to Makefile.PL script.  Trace PERLARGS
# for details.  The Makefile for perl modules was not generated at configure
# time, but at build time with Makefile
#
# - http://modperlbook.org/html/3-9-1-Installing-Perl-Modules-into-a-Nonstandard-Directory.html
CONFIGURE_ARGS="									\\
	--with-defaults									\\
	--with-perl-modules='PREFIX=$INSTALL_PREFIX'	\\
"
