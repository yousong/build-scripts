#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=easy-rsa
PKG_VERSION=3.0.1
PKG_SOURCE="EasyRSA-$PKG_VERSION.tgz"
PKG_SOURCE_URL="https://github.com/OpenVPN/easy-rsa/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5fd4b1a07983a517484bf57c31f7befb
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=openssl

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# This was partially borrowed from MacPorts
	patch -p0 <<"EOF"
--- easyrsa.orig	2015-09-10 07:18:15.000000000 +0800
+++ easyrsa	2016-01-29 13:51:46.000000000 +0800
@@ -977,7 +977,7 @@ vars_setup() {
 	local vars=
 
 	# set up program path
-	local prog_vars="${0%/*}/vars"
+	local prog_vars="PREFIX/share/easy-rsa"
 
 	# command-line path:
 	if [ -f "$EASYRSA_VARS_FILE" ]; then
@@ -1002,9 +1002,9 @@ Note: using Easy-RSA configuration from:
 	fi
 	
 	# Set defaults, preferring existing env-vars if present
-	set_var EASYRSA		"$PWD"
+	set_var EASYRSA		"PREFIX/share/easy-rsa"
 	set_var EASYRSA_OPENSSL	openssl
-	set_var EASYRSA_PKI	"$EASYRSA/pki"
+	set_var EASYRSA_PKI	"$PWD/pki"
 	set_var EASYRSA_DN	cn_only
 	set_var EASYRSA_REQ_COUNTRY	"US"
 	set_var EASYRSA_REQ_PROVINCE	"California"
--- vars.example.orig	2015-09-03 07:10:26.000000000 +0800
+++ vars.example	2016-01-29 13:51:46.000000000 +0800
@@ -42,7 +42,7 @@ fi
 # This variable should point to the top level of the easy-rsa tree. By default,
 # this is taken to be the directory you are currently in.
 
-#set_var EASYRSA	"$PWD"
+#set_var EASYRSA	"PREFIX/share/easy-rsa"
 
 # If your OpenSSL command is not in the system PATH, you will need to define the
 # path to it here. Normally this means a full path to the executable, otherwise
@@ -62,7 +62,7 @@ fi
 # WARNING: init-pki will do a rm -rf on this directory so make sure you define
 # it correctly! (Interactive mode will prompt before acting.)
 
-#set_var EASYRSA_PKI		"$EASYRSA/pki"
+#set_var EASYRSA_PKI		"$PWD/pki"
 
 # Define X509 DN mode.
 # This is used to adjust what elements are included in the Subject field as the DN
--- /dev/null	2015-09-03 07:10:26.000000000 +0800
+++ Makefile	2016-01-29 13:51:46.000000000 +0800
@@ -0,0 +1,12 @@
+install:
+	install -d "$(DESTDIR)$(PREFIX)/bin"
+	install -m 755 easyrsa "$(DESTDIR)$(PREFIX)/bin"
+
+	install -d "$(DESTDIR)$(PREFIX)/share/easy-rsa/x509-types"
+	install -m 640 openssl-1.0.cnf vars.example "$(DESTDIR)$(PREFIX)/share/easy-rsa"
+	install -m 640 x509-types/* "$(DESTDIR)$(PREFIX)/share/easy-rsa/x509-types"
+
+	install -d "$(DESTDIR)$(PREFIX)/share/doc/easy-rsa"
+	install -m 640 COPYING ChangeLog gpl-2.0.txt README.quickstart.md \
+		"$(DESTDIR)$(PREFIX)/share/doc/easy-rsa"
+	install -m 640 doc/* "$(DESTDIR)$(PREFIX)/share/doc/easy-rsa"
EOF
	sed -i'' -e "s|PREFIX|$INSTALL_PREFIX|g" easyrsa
	sed -i'' -e "s|PREFIX|$INSTALL_PREFIX|g" vars.example
}

configure() {
	true
}

compile() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
