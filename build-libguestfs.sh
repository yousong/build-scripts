#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# libguestfs dependency
#
#	@supermin
#	@augeas
#	sudo apt-get install genisoimage
#	# required by supermin appliance
#	sudo apt-get install lvm2 parted
#
# extra notes
#
# - For downloading ready-made images, http://libguestfs.org/download/builder/
# - guestfsd depends on debian package libaugeas0.  Yet the one from wheezy is too old.
# - virt-sparsify depends on lvm2 (see appliance/packagelist.in)
# - virt-sysprep depends on parted (see appliance/packagelist.in)
#
# libguestfs does not work on CentOS 6 at the moment because supermin fails to
# detect RPM and installing rpm-devel with yum will fail the supermin build
#
# - CentOS 6.4: Supermin fails to detect RPM based distro, https://bugzilla.redhat.com/show_bug.cgi?id=1082044
# - You are not authorized to access bug #1286432, https://bugzilla.redhat.com/show_bug.cgi?id=1286432
#
PKG_NAME=libguestfs
PKG_VERSION=1.40.2
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://libguestfs.org/download/${PKG_VERSION%.*}-stable/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7cf90b71013c83f28fead844d3b343ea
PKG_AUTOCONF_FIXUP=1
PKG_DEPENDS='augeas file gperf hivex jansson libxml2 pcre qemu supermin'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# Those added files in hostfiles.in are needed as they are built by
	# ourselves and are not covered by packages listed in packages.in
	#
	# Specifically, that libpcre.* is there even though we have libpcre3 in
	# packages.in is because Debian's libpcre3 provides libpcre.so.3.x.x
	# instead of libpcre.so.1.x.y needed by sbin/guestfsd
	#
	# Also note that these included files will have identical path as how they
	# are specified, that is $INSTALL_PREFIX will be reconstructured in the
	# result appliance
	#
	# Another option would be to disable supermin altogether and used a
	# downloaded appliance
	patch -p1 <<EOF
--- a/appliance/hostfiles.in.orig 2015-12-12 15:36:10.002586624 +0800
+++ b/appliance/hostfiles.in      2015-12-12 15:36:42.770595842 +0800
@@ -16,3 +16,7 @@
 /etc/ld.so.cache
 /lib/lsb/*
 /usr/share/augeas/lenses/*.aug
+$INSTALL_PREFIX/lib/libaugeas.*
+$INSTALL_PREFIX/lib/libfa.*
+$INSTALL_PREFIX/lib/libpcre.*
+$INSTALL_PREFIX/share/augeas/lenses/dist/*
--- a/builder/paths.ml.orig	2015-12-14 11:57:27.104578901 +0800
+++ b/builder/paths.ml	2015-12-14 11:57:48.788586611 +0800
@@ -36,7 +36,7 @@ let xdg_config_home () =
 let xdg_config_dirs () =
   let dirs =
     try Sys.getenv "XDG_CONFIG_DIRS"
-    with Not_found -> "/etc/xdg" in
+    with Not_found -> "$INSTALL_PREFIX/etc/xdg" in
   let dirs = String.nsplit ":" dirs in
   let dirs = List.filter (fun x -> x <> "") dirs in
   List.map (fun x -> x // prog) dirs
EOF
	patch -p1 <<"EOF"
--- a/m4/guestfs-bash-completion.m4.orig	2015-12-12 10:44:43.397114670 +0800
+++ b/m4/guestfs-bash-completion.m4	2015-12-12 10:44:58.069115522 +0800
@@ -19,7 +19,7 @@ dnl Bash completion.
 PKG_CHECK_MODULES([BASH_COMPLETION], [bash-completion >= 2.0], [
     bash_completion=yes
     AC_MSG_CHECKING([for bash-completions directory])
-    BASH_COMPLETIONS_DIR="`pkg-config --variable=completionsdir bash-completion`"
+    BASH_COMPLETIONS_DIR="$datadir/bash-completion/completions"
     AC_MSG_RESULT([$BASH_COMPLETIONS_DIR])
     AC_SUBST([BASH_COMPLETIONS_DIR])
 ],[
--- a/ocaml/Makefile.am.orig	2019-03-15 08:24:54.286174841 +0000
+++ b/ocaml/Makefile.am	2019-03-15 08:25:21.820195639 +0000
@@ -183,16 +183,16 @@ data_hook_files += *.cmx *.cmxa
 endif
 
 install-data-hook:
-	mkdir -p $(DESTDIR)$(OCAMLLIB)
-	mkdir -p $(DESTDIR)$(OCAMLLIB)/stublibs
-	rm -rf $(DESTDIR)$(OCAMLLIB)/guestfs
-	rm -rf $(DESTDIR)$(OCAMLLIB)/stublibs/dllmlguestfs.so*
+	mkdir -p $(DESTDIR)$(libdir)/ocaml
+	mkdir -p $(DESTDIR)$(libdir)/ocaml/stublibs
+	rm -rf $(DESTDIR)$(libdir)/ocaml/guestfs
+	rm -rf $(DESTDIR)$(libdir)/ocaml/stublibs/dllmlguestfs.so*
 	$(OCAMLFIND) install \
-	  -ldconf ignore -destdir $(DESTDIR)$(OCAMLLIB) \
+	  -ldconf ignore -destdir $(DESTDIR)$(libdir)/ocaml \
 	  guestfs \
 	  $(data_hook_files)
-	rm -f $(DESTDIR)$(OCAMLLIB)/guestfs/bindtests.*
-	rm $(DESTDIR)$(OCAMLLIB)/guestfs/libguestfsocaml.a
+	rm -f $(DESTDIR)$(libdir)/ocaml/guestfs/bindtests.*
+	rm $(DESTDIR)$(libdir)/ocaml/guestfs/libguestfsocaml.a
 
 CLEANFILES += $(noinst_DATA) $(check_DATA)
 
EOF
}

# ocaml and perl bindings need to be enabled for OCaml and Perl based virt
# tools, e.g. virt-sparsify is part of ocaml support
CONFIGURE_ARGS+=(
	--disable-nls
	--disable-python
	--disable-ruby
	--disable-haskell
	--disable-php
	--disable-erlang
	--disable-lua
	--disable-golang
	--disable-gobject
)
