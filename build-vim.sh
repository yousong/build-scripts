#!/bin/bash -e
#
# Copyright 2015-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Vim on Debian Wheezy 7 has version 7.3.547 (Fetched with command "vim --version")
#
#	sudo apt-get build-dep vim-nox
#	sudo apt-get install gawk
#
# Vim on CentOS 7 has version 7.4.160
#
#	sudo yum-builddep vim-enhanced
#	# or use the following method if you are on CentOS 6.5
#	sudo yum install -y ruby-devel ncurses-devel perl-devel perl-ExtUtils-Embed
#
# 7.3 is the release version.
# 547 is the number of applied patches provided by vim.org.
PKG_NAME=vim
PKG_VERSION=8.0.1605
PKG_SOURCE="vim-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/vim/vim/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=a6c106007802755765616fb03f8aaec6
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libiconv LuaJIT ncurses python2'

. "$PWD/env.sh"

VIM_VER_MAJ="$(echo $PKG_VERSION | cut -d. -f1-2)"
VIM_PATCH_DIR="$BASE_DL_DIR/vim$VIM_VER_MAJ-patches"

# vim starting with 8.0 now offers patched tar.bz2, then we can set range
# additional patches to apply.
#
# The problem was that those patches were not generated properly and failed to
# apply for various (sometimes unknown) reasons
#
#  - Patch 1425 of vim 7.4 seems malformed at the moment (2016-09-14) when
#    patching csdpmi4b.zip
#  - vim-8.0.tar.bz2 at the moment already has patch 0001 and 0002 applied
#  - applying testxx.in often fails with "Already applied, reverse?"
#
VIM_PATCH_START="$(echo "$PKG_VERSION" | cut -d. -f3)"
VIM_PATCH_START="${VIM_PATCH_START#000}"
VIM_PATCH_START="${VIM_PATCH_START#00}"
VIM_PATCH_START="${VIM_PATCH_START#0}"
VIM_PATCH_START="$(($VIM_PATCH_START + 1))"
VIM_PATCH_END=9999

vim_patches_all_fetched() {
	if sed -n "${VIM_PATCH_START},${VIM_PATCH_END}p" MD5SUMS | md5sum --status -c; then
		return 0
	else
		return 1
	fi
}

vim_init_patch_num() {
	VIM_PATCH_TOTAL="$(wc -l MD5SUMS | cut -f1 -d' ')"
	if [ -z "$VIM_PATCH_START" ]; then
		VIM_PATCH_START=1
	fi
	if [ -z "$VIM_PATCH_END" -o "$VIM_PATCH_END" -gt "$VIM_PATCH_TOTAL" ]; then
		VIM_PATCH_END="$VIM_PATCH_TOTAL"
	fi
}

fetch_patches() {
	local ver="$PKG_VERSION"
	local baseurl="ftp://ftp.vim.org/pub/vim/patches/$VIM_VER_MAJ"
	local ttl_patches dl_patches
	local num_process
	local i l

	mkdir -p "$VIM_PATCH_DIR"
	cd "$VIM_PATCH_DIR"

	if [ -s "MD5SUMS" ]; then
		vim_init_patch_num
		if vim_patches_all_fetched; then
			__errmsg "All fetched, skip fetching patches"
			return 0
		fi
	fi

	# delete MD5SUMS to check for new patches
	wget -c "$baseurl/MD5SUMS"
	vim_init_patch_num
	for i in $(seq "$VIM_PATCH_START" 100 "$VIM_PATCH_END"); do
		# Each wget fetches at most 100 patches.
		sed -n "$i,$(($i+99))p" MD5SUMS | \
			while read l; do echo "$l" | md5sum --status -c || echo "$baseurl/${l##* }"; done | \
			wget --no-verbose -c -i - &
	done
	wait

	if ! vim_patches_all_fetched; then
		__errmsg "Some patches were missing"
		return 1
	fi
}

apply_patches() {
	local f
	local re_start="^.*\\/$VIM_VER_MAJ.0*$VIM_PATCH_START\$"
	local re_end="^.*\\/$VIM_VER_MAJ.0*$VIM_PATCH_END\$"

	cd "$PKG_BUILD_DIR"

	if [ -f ".patched" ]; then
		__errmsg "$PKG_BUILD_DIR/.patched exists, skip patching."
		return 0
	fi

	for f in $(ls "$VIM_PATCH_DIR/$VIM_VER_MAJ."* | sort --version-sort | sed -n "/$re_start/,/$re_end/p"); do
		__errmsg "applying patch $f"
		patch -p0 -i "$f"
		__errmsg
	done
	touch .patched
}

do_patch() {
	# "patch 8.0.0203: order of complication flags is sometimes wrong" is
	# required to make the build system prefer libraries from $INSTALL_PREFIX
	#
	# commented out for now as applying patches manually do not work as
	# expected at the moment (2017.01.21)
	#
	#fetch_patches
	#apply_patches
	true

	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
From e182ba75d893b686d8db89a69dcb0b494d2eddb7 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Wed, 22 Mar 2017 11:51:48 +0800
Subject: [PATCH] pythoncomplete: quash possible messages from evaling user
 code

Problem:  Python packages like scapy outputs fair amount of warning
          messages at import time when detecting its runtime
          environment.  This is irrelevant in the context of
          pythoncomplete
Solution: silent! the vimcomplete python call and unsilent the showdbg
          call there within
---
 runtime/autoload/pythoncomplete.vim | 78 +++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 37 deletions(-)

diff --git a/runtime/autoload/pythoncomplete.vim b/runtime/autoload/pythoncomplete.vim
index ecc3664..c9d7da0 100644
--- a/runtime/autoload/pythoncomplete.vim
+++ b/runtime/autoload/pythoncomplete.vim
@@ -81,63 +81,67 @@ function! pythoncomplete#Complete(findstart, base)
                 break
             endif
         endwhile
-        execute "python vimcomplete('" . cword . "', '" . a:base . "')"
+        silent! execute "python vimcomplete('" . cword . "', '" . a:base . "')"
         return g:pythoncomplete_completions
     endif
 endfunction
 
 function! s:DefPython()
 python << PYTHONEOF
+import vim
 import sys, tokenize, cStringIO, types
 from token import NAME, DEDENT, NEWLINE, STRING
 
 debugstmts=[]
 def dbg(s): debugstmts.append(s)
 def showdbg():
-    for d in debugstmts: print "DBG: %s " % d
+    for d in debugstmts: vim.command("unsilent echom 'DBG: '%r" % d)
 
 def vimcomplete(context,match):
     global debugstmts
     debugstmts = []
     try:
-        import vim
-        def complsort(x,y):
-            try:
-                xa = x['abbr']
-                ya = y['abbr']
-                if xa[0] == '_':
-                    if xa[1] == '_' and ya[0:2] == '__':
-                        return xa > ya
-                    elif ya[0:2] == '__':
-                        return -1
-                    elif y[0] == '_':
-                        return xa > ya
-                    else:
-                        return 1
-                elif ya[0] == '_':
-                    return -1
-                else:
-                   return xa > ya
-            except:
-                return 0
-        cmpl = Completer()
-        cmpl.evalsource('\n'.join(vim.current.buffer),vim.eval("line('.')"))
-        all = cmpl.get_completions(context,match)
-        all.sort(complsort)
-        dictstr = '['
-        # have to do this for double quoting
-        for cmpl in all:
-            dictstr += '{'
-            for x in cmpl: dictstr += '"%s":"%s",' % (x,cmpl[x])
-            dictstr += '"icase":0},'
-        if dictstr[-1] == ',': dictstr = dictstr[:-1]
-        dictstr += ']'
-        #dbg("dict: %s" % dictstr)
-        vim.command("silent let g:pythoncomplete_completions = %s" % dictstr)
-        #dbg("Completion dict:\n%s" % all)
+        vimcomplete_(context, match)
     except vim.error:
         dbg("VIM Error: %s" % vim.error)
 
+def vimcomplete_(context,match):
+    cmpl = Completer()
+    cmpl.evalsource('\n'.join(vim.current.buffer),vim.eval("line('.')"))
+    all = cmpl.get_completions(context,match)
+    all.sort(complsort)
+    dictstr = '['
+    # have to do this for double quoting
+    for cmpl in all:
+        dictstr += '{'
+        for x in cmpl: dictstr += '"%s":"%s",' % (x,cmpl[x])
+        dictstr += '"icase":0},'
+    if dictstr[-1] == ',': dictstr = dictstr[:-1]
+    dictstr += ']'
+    #dbg("dict: %s" % dictstr)
+    vim.command("let g:pythoncomplete_completions = %s" % dictstr)
+    #dbg("Completion dict:\n%s" % all)
+
+def complsort(x,y):
+    try:
+        xa = x['abbr']
+        ya = y['abbr']
+        if xa[0] == '_':
+            if xa[1] == '_' and ya[0:2] == '__':
+                return xa > ya
+            elif ya[0:2] == '__':
+                return -1
+            elif y[0] == '_':
+                return xa > ya
+            else:
+                return 1
+        elif ya[0] == '_':
+            return -1
+        else:
+           return xa > ya
+    except:
+        return 0
+
 class Completer(object):
     def __init__(self):
        self.compldict = {}
-- 
2.6.4
EOF
}

# +profile feature is only available through HUGE features set.  It cannot
# enabled standalone through configure options.  See how FEAT_PROFILE was
# defined in src/feature.h
CONFIGURE_ARGS+=(
	--enable-fail-if-missing
	--enable-luainterp
	--disable-perlinterp
	--enable-pythoninterp
	--disable-rubyinterp
	--enable-cscope
	--enable-multibyte
	--disable-gui
	--disable-gtktest
	--disable-xim
	--without-x
	--disable-netbeans
	--with-luajit
	--with-lua-prefix="$INSTALL_PREFIX"
	--with-tlib=ncurses
	--with-features=huge
)

configure_pre() {
	cd "$PKG_SOURCE_DIR/src"
	"${MAKEJ[@]}" autoconf
}
