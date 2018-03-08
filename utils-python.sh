#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
do_patch_python23() {
	if ! os_is_darwin; then
		return 0
	fi

	# for building pyexpat module
	# taken from: https://github.com/LibreOffice/core/blob/master/external/python3/python-3.3.5-pyexpat-symbols.patch.1
	patch -p0 <<"EOF"
HACK: Fix build breakage on MacOS:

*** WARNING: renaming "pyexpat" since importing it failed: dlopen(build/lib.macosx-10.6-i386-3.3/pyexpat.so, 2): Symbol not found: _XML_ErrorString

This reverts c242a8f30806 from the python hg repo:

restore namespacing of pyexpat symbols (closes #19186)


See http://bugs.python.org/issue19186#msg214069

The recommendation to include Modules/inc at first broke the Linux build...

So do it this way, as it was before. Needs some realignment later.

--- Modules/expat/expat_external.h
+++ Modules/expat/expat_external.h
@@ -7,10 +7,6 @@

 /* External API definitions */

-/* Namespace external symbols to allow multiple libexpat version to
-   co-exist. */
-#include "pyexpatns.h"
-
 #if defined(_MSC_EXTENSIONS) && !defined(__BEOS__) && !defined(__CYGWIN__)
 #define XML_USE_MSC_EXTENSIONS 1
 #endif
EOF
}

do_patch_python2() {
	true
}
