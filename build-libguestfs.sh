#!/bin/sh -e
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
PKG_NAME=libguestfs
PKG_VERSION=1.30.2
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://libguestfs.org/download/${PKG_VERSION%.*}-stable/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6c5632779d13c0bf4a88724af71c6bc8

. "$PWD/env.sh"

# ocaml and perl bindings need to be enabled for OCaml and Perl based virt
# tools, e.g. virt-sparsify is part of ocaml support
CONFIGURE_ARGS='			\
	--disable-nls			\
	--disable-python		\
	--disable-ruby			\
	--disable-haskell		\
	--disable-php			\
	--disable-erlang		\
	--disable-lua			\
	--disable-golang		\
	--disable-gobject		\
'

do_patch() {
    cd "$PKG_BUILD_DIR"

	patch -p1 <<EOF
--- a/appliance/hostfiles.in.orig 2015-12-12 15:36:10.002586624 +0800
+++ b/appliance/hostfiles.in      2015-12-12 15:36:42.770595842 +0800
@@ -15,3 +15,6 @@ dnl   MAGEIA=1     For Mageia.

 /lib/lsb/*
 /usr/share/augeas/lenses/*.aug
+$INSTALL_PREFIX/lib/libaugeas.*
+$INSTALL_PREFIX/lib/libfa.*
+$INSTALL_PREFIX/share/augeas/lenses/dist/*
--- a/builder/paths.ml.orig	2015-12-14 11:57:27.104578901 +0800
+++ b/builder/paths.ml	2015-12-14 11:57:48.788586611 +0800
@@ -35,7 +35,7 @@ let xdg_config_home () =
 let xdg_config_dirs () =
   let dirs =
     try Sys.getenv "XDG_CONFIG_DIRS"
-    with Not_found -> "/etc/xdg" in
+    with Not_found -> "$INSTALL_PREFIX/etc/xdg" in
   let dirs = string_nsplit ":" dirs in
   let dirs = List.filter (fun x -> x <> "") dirs in
   List.map (fun x -> x // prog) dirs
EOF
	patch -p1 <<"EOF"
--- a/configure.ac.orig	2015-12-12 10:44:43.397114670 +0800
+++ b/configure.ac	2015-12-12 10:44:58.069115522 +0800
@@ -1647,7 +1647,7 @@ dnl Bash completion.
 PKG_CHECK_MODULES([BASH_COMPLETION], [bash-completion >= 2.0], [
     bash_completion=yes
     AC_MSG_CHECKING([for bash-completions directory])
-    BASH_COMPLETIONS_DIR="`pkg-config --variable=completionsdir bash-completion`"
+    BASH_COMPLETIONS_DIR="$datadir/bash-completion/completions"
     AC_MSG_RESULT([$BASH_COMPLETIONS_DIR])
     AC_SUBST([BASH_COMPLETIONS_DIR])
 ],[
--- a/ocaml/Makefile.am.orig	2015-12-12 10:16:49.700585819 +0800
+++ b/ocaml/Makefile.am	2015-12-12 10:17:44.040602943 +0800
@@ -195,14 +195,14 @@ data_hook_files += *.cmx *.cmxa
 endif
 
 install-data-hook:
-	mkdir -p $(DESTDIR)$(OCAMLLIB)
-	mkdir -p $(DESTDIR)$(OCAMLLIB)/stublibs
+	mkdir -p $(DESTDIR)$(libdir)/ocaml
+	mkdir -p $(DESTDIR)$(libdir)/ocaml/stublibs
 	$(OCAMLFIND) install \
-	  -ldconf ignore -destdir $(DESTDIR)$(OCAMLLIB) \
+	  -ldconf ignore -destdir $(DESTDIR)$(libdir)/ocaml \
 	  guestfs \
 	  $(data_hook_files)
-	rm $(DESTDIR)$(OCAMLLIB)/guestfs/bindtests.*
-	rm $(DESTDIR)$(OCAMLLIB)/guestfs/libguestfsocaml.a
+	rm $(DESTDIR)$(libdir)/ocaml/guestfs/bindtests.*
+	rm $(DESTDIR)$(libdir)/ocaml/guestfs/libguestfsocaml.a
 
 CLEANFILES += $(noinst_DATA)
 
EOF
}

configure_pre() {
	cd "$PKG_BUILD_DIR"
	autoreconf
}

