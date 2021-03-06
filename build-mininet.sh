#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Requires help2man
#
# 	sudo yum install -y help2man
#
# Read util/install.sh to see those companion components available
#
# Read bin/nm to get started
#
# Read mininet/*.py for details
#
#	topo.py			How topologies are represented
#	topolib.py		Additional topos like tree, 2-d torus
#
# Network hosts are emulated by spawning bash processes in separate network namespaces
#
#	bash --norc -is mininet:hN
#
# The namespace thing etc. are handled by mnexec.c.  Note that mininet uses
# nameless namespaces and as such 'ip netns list-id' command will be needed to
# identify them
#
# Examples
#
#	# 1 switch with 3 hosts
#	sudo mn --topo single,k=3 --mac --controller none --switch ovsk,failMode=standalone,protocols=OpenFlow10
#
#	# this requires a remote controller like ryu
#	sudo mn --topo linear,k=3,n=4 --mac --controller remote --switch ovsk,protocols=OpenFlow13
#	sudo mn --topo tree,depth=2,fanout=2 --mac --controller remote --switch ovsk,protocols=OpenFlow13
#
#	# custom topo
#	sudo mn --custom topo.py --topo 2hostNintf,n=3 --mac --controller none --switch ovsk,failMode=standalone,protocols=OpenFlow10
#
# To use mnexec
#
#	- use 'dump' command from mininet console to find out pid of bash process of each host
#	- attach to pid's network and mount namespaces
#
#		sudo mnexec -a 22617 bash
#
# mn should be enough for most tasks with options
#
#	--custom file1.py,file2.py
#	--pre cli.batch.file
#
# and py (eval) and px (exec) commands.  --custom will use execfile instead.
#
# - Mininet system-level tests, benchmarks, and performance monitoring,
#   https://github.com/mininet/mininet-tests.git
#
#   Old repo and may need modification to work with current version of mininet.
#   Can be useful for inspirations
#
PKG_NAME=mininet
PKG_VERSION=2.2.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/mininet/mininet/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=6d19e8b8865805a2af91ee5600bec385
PKG_DEPENDS='openvswitch python2'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
diff --git a/Makefile b/Makefile
index a5ead63..f8ee3ab 100644
--- a/Makefile
+++ b/Makefile
@@ -8,8 +8,8 @@ PYSRC = $(MININET) $(TEST) $(EXAMPLES) $(BIN)
 MNEXEC = mnexec
 MANPAGES = mn.1 mnexec.1
 P8IGN = E251,E201,E302,E202,E126,E127,E203,E226
-BINDIR = /usr/bin
-MANDIR = /usr/share/man/man1
+BINDIR = $(PREFIX)/bin
+MANDIR = $(PREFIX)/share/man/man1
 DOCDIRS = doc/html doc/latex
 PDF = doc/latex/refman.pdf
 
@@ -47,9 +47,10 @@ mnexec: mnexec.c $(MN) mininet/net.py
 	cc $(CFLAGS) $(LDFLAGS) -DVERSION=\"`PYTHONPATH=. $(PYMN) --version`\" $< -o $@
 
 install: $(MNEXEC) $(MANPAGES)
-	install $(MNEXEC) $(BINDIR)
-	install $(MANPAGES) $(MANDIR)
-	python setup.py install
+	mkdir -p $(DESTDIR)$(BINDIR) $(DESTDIR)$(MANDIR)
+	install $(MNEXEC) $(DESTDIR)$(BINDIR)
+	install $(MANPAGES) $(DESTDIR)$(MANDIR)
+	python setup.py install --root="$(DESTDIR)" --prefix="$(PREFIX)"
 
 develop: $(MNEXEC) $(MANPAGES)
 # 	Perhaps we should link these as well
EOF
}

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)

compile() {
	# there is nothing to compile except docs which will be generated when
	# doing install.  Other than that, the default all target will do tests
	true
}
