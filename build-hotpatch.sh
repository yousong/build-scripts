#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Code injection and run without need of recompiling target program.  This
# means hotpatch can only patch by adding code, not replacing or modifying
# existing ones
#
# Examples
#
#	gcc -fPIC -shared -o hello.{so,c}
#	sleep 7200
#	# hotpatch_inject_library() can pass a single argument to the function to
#	# be called which is NULL with hotpatcher
#	sudo `which hotpatcher` -l $PWD/world.so -s hello $(pgrep sleep)
#
# HOWTO and NOTES
#
# - Use ptrace() to pause/resume, get/set regs, peek/write memory of the target
#   process, then we have complete control of the target process
# - Use dlopen() (provided by libdl.so) or __libc_dlopen_mode() (provided by
#	libc.so)to load library
# - Use dlsym() or __libc_dlsym() to find the symbol
# - To find addresses of dlopen() and dlsym() in the target process
#   - Parse the content of /proc/<pid>/maps
#   - Find the path to and base address of the library
#   - Parse the ELF file and find the offset
#   - Check commit 75149b8c to see how to compute the address
# - NULL will be written to return address in the stack to cause SIGSEGV and
#   thus allow the patcher to again take control after PTRACE_CONT.  See
#   HP_NULLIFYSTACK and HP_SETEXECWAITGET
#
# Another way to find symbols' address in target process.  The code needs to
# compiled with -fPIC
#
# - Load the same library in the loader process
# - Find the base addresses of the library in both loader and target processes
# - Use dlsym() to find the symbol in current process
# - The offset will be the same both in the loader and target processes, then
#   we can compute the symbol's address by using base address of the library in
#   the target process and shared offset.
#
# dlopen() flags
#
# - RTLD_LAZY | RTLD_GLOBAL are used in hotpatch which will resolve symbols at
#   first-use and make global variables in the loaded library also available to
#   other future libraries to be loaded
# - RTLD_NOW, resolve symbols before dlopen() returns and returns error if this
#   cannot be done
#
# We can also use __attribute__((constructor)) to run injected code at load time
#
# If we want to patch existing code (or to replace it) in the target process
#
# - Find the prolog address of the target function to be patched
# - Call mprotect() in the target process to make the region writable
# - Overwrite initial several insts bo jump unconditionally target code
#
#		mov $new_func %rac
#		jmp %rax
#
#   Read the ABI doc if in doubt
#
# To make patch.so
#
# - Compile with -ffunction-sections and -fdata-sections, then compare the difference
# - Find in the patched code where references to other parts functions and data
# - Resolve them and write the result to memory
# - libbfd, libelf can be useful on this task
#
# Threading must be taken into consideration when patching code
#
# - Pause all threads, and check if any new ones get created in that process and repeat if there are
# - Check if the func to be patched is still on any of the stacks of current
#   threads.  If it is, then it's not safe to patch the code at the moment
# - NOTE: we need to record the threads' current running status before pausing
#   them so that we can decide later whether to resume them at all?
# - libthread_db, /proc/<pid>/tasks can be used to gather and manipulate threads info
#
# Refs
#
# - 如何用几行代码打造应用程序热补丁？（一）, https://zhuanlan.zhihu.com/p/25752198
# - 应用程序热补丁（二）：自动生成热补丁, http://www.infoq.com/cn/news/2017/04/Application-hot-patch-2
# - 应用程序热补丁（三）：完整的设计与实现, http://www.infoq.com/cn/news/2017/04/Application-hot-patch-3
# - The Linux Standard Base spec, https://refspecs.linuxfoundation.org/lsb.shtml
# - http://www.cs.stevens.edu/~jschauma/810/elf.html
# - Linkers series by Ian Lance Taylor, http://www.airs.com/blog/index.php?s=Linkers, or http://a3f.at/lists/linkers
#
PKG_NAME=hotpatch
PKG_VERSION=2013-12-02
PKG_SOURCE_VERSION=4b65e3f275739ea5aa798d4ad083c4cb10e29149
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/vikasnkumar/hotpatch/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"
