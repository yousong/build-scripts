#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=easy-rsa
PKG_VERSION=3.0.4
PKG_SOURCE="EasyRSA-$PKG_VERSION.tgz"
PKG_SOURCE_URL="https://github.com/OpenVPN/easy-rsa/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d163f0681b4b2067f107badeb9151629
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=openssl

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# This was partially borrowed from MacPorts
	#
	# EasyRSA is designed to be run as is after extraction where the
	# executable and configuration data reside in the same directory.
	#
	# We separate them into bin/ and share/easy-rsa directory.  The change
	# affects lookup path for "vars" file.  See vars_setup() in easyrsa
	# script for details
	patch -p0 <<"EOF"
--- easyrsa.orig	2018-08-16 02:19:54.520252458 +0000
+++ easyrsa	2018-08-16 02:21:34.049191557 +0000
@@ -1033,7 +1033,7 @@ vars_setup() {
 	vars=
 
 	# set up program path
-	prog_vars="${0%/*}/vars"
+	prog_vars="PREFIX/share/easy-rsa/vars"
 	# set up PKI path
 	pki_vars="${EASYRSA_PKI:-$PWD/pki}/vars"
 
@@ -1060,7 +1060,7 @@ Note: using Easy-RSA configuration from:
 	fi
 	
 	# Set defaults, preferring existing env-vars if present
-	set_var EASYRSA		"${0%/*}"
+	set_var EASYRSA		"PREFIX/share/easy-rsa"
 	set_var EASYRSA_OPENSSL	openssl
 	set_var EASYRSA_PKI	"$PWD/pki"
 	set_var EASYRSA_DN	cn_only
--- vars.example.orig	2018-08-16 02:22:11.223794717 +0000
+++ vars.example	2018-08-16 02:22:13.704768222 +0000
@@ -47,7 +47,7 @@ fi
 # itself, which is also where the configuration files are located in the
 # easy-rsa tree.
 
-#set_var EASYRSA	"${0%/*}"
+#set_var EASYRSA	"PREFIX/share/easy-rsa"
 
 # If your OpenSSL command is not in the system PATH, you will need to define the
 # path to it here. Normally this means a full path to the executable, otherwise
--- /dev/null	2015-09-03 07:10:26.000000000 +0800
+++ Makefile	2016-01-29 13:51:46.000000000 +0800
@@ -0,0 +1,19 @@
+install:
+	install -d "$(DESTDIR)$(PREFIX)/bin"
+	install -m 755 easyrsa "$(DESTDIR)$(PREFIX)/bin"
+
+	install -d "$(DESTDIR)$(PREFIX)/share/easy-rsa/x509-types"
+	install -m 640 \
+			openssl-easyrsa.cnf \
+			vars.example \
+		"$(DESTDIR)$(PREFIX)/share/easy-rsa"
+	install -m 640 x509-types/* "$(DESTDIR)$(PREFIX)/share/easy-rsa/x509-types"
+
+	install -d "$(DESTDIR)$(PREFIX)/share/doc/easy-rsa"
+	install -m 640 \
+			COPYING.md \
+			ChangeLog \
+			gpl-2.0.txt \
+			README.quickstart.md \
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
