Scripts for quickly building/installing specified versions of projects from source code to specified locations.

- Edit `env.sh` settings before building
- Not trying to be foolproof

	Previously experience with the target project and some shell scripting experience is expected

- Scripts are executed with `/bin/sh -e`
- Try to be reentrant
- Use absolute path

## Prerequisites

	GNU wget
	GNU tar, command line option --transform support
	patch
	uudecode, can be provided by debian package sharutils
	md5sum
	git
	make
	cmake
	autoconf, there are times we need to patch configure.ac and regenerate configure script with autoreconf

## How to use this

Compile one by one and handle dependencies by mind

	# download, prepare, configure, compile, staging
	./build-nginx-vanilla.sh till staging

	# single action configure
	./build-nginx-vanilla.sh till configure

	# remove build_dir/nginx-1.9.9
	./build-nginx-vanilla.sh clean

	# uninstall based on dest_dir/nginx-1.9.9-install
	./build-nginx-vanilla.sh uninstall

Compile with `Makefile`

	# download, prepare, configure, compile, staging
	make nginx/staging

	# same but only happens in tests_dir/
	make nginx/staging/test

	# do them all
	make download
	make staging
	make install/test

## Tips

On CentOS 6.6, manpages installed manually cannot be found by `man` command by default.  To solve this

	# Try adding something like the following to `/etc/man.config`
	MANPATH_MAP	/home/yousong/.usr/bin	/home/yousong/.usr/share/man
	# Or, setting MANPATH variable as such
	MANPATH="$INSTALL_PREFIX/share/man:$(manpath)"

Many of the times packages depend on the installation of other packages to be successfully built and run.  Currently we just use the distribution's package manager to install those dependencies for us.

	apt-get install build-essential
	apt-get build-dep openvpn
	apt-cache showsrc openvpn | grep Build-Depends

	yum -y groupinstall "Development Tools"
	yum-builddep openvpn

When dependencies cannot be satisfied by system package manager, we build the required version ourself.

## Versioned symbols

On Debian, Warning messages like the follow can be emitted by dynamic loader

	/usr/bin/curl: /home/yousong/.usr/lib/libcurl.so.4: no version information available (required by /usr/bin/curl)
	/home/yousong/.usr/sbin/openvpn: /home/yousong/.usr/lib/libssl.so.1.0.0: no version information available (required by /home/yousong/.usr/sbin/openvpn)
	/home/yousong/.usr/sbin/openvpn: /home/yousong/.usr/lib/libcrypto.so.1.0.0: no version information available (required by /home/yousong/.usr/sbin/openvpn)

These informations are most likely related to libraries provided by OpenSSL (`libcrypto.so` and `libssl.so`)

The first message about `curl` was caused by the following facts

- `/usr/bin/curl` was provided by `apt-get` and was configured with `--enable-versioned-symbols`, so the result binary references (depends on) those symbols (`CURL_OPENSSL_3`)
- `libcurl.so` built by us does not enable that configure option, so the result library is missing the symbol
- The `ldd /usr/bin/curl` was run with `LD_LIBRARY_PATH` being set to `$INSTALL_PREFIX/lib` causing the loader to first look for and find the libcurl there provided by us

The messages about `openvpn` was caused by the following facts

- That `openvpn` binary was built before we have OpenSSL libraries present in `$INSTALL_PREFIX/lib`
- That `openvpn` binary references (depends on) symbol `OPENSSL_1.0.0` as is provided by OpenSSL libraries provided by `apt-get`
- Then custom OpenSSL libraries were built by us
- Then `RPATH` still points the loader to first lookup the library in `$INSTALL_PREFIX/lib`
- Then loader found that the versioned symbol information is missing

To solve the problem

- `unset LD_LIBRARY_PATH` or just remove `$INSTALL_PREFIX/lib` from `$LD_LIBRARY_PATH`
- Rebuild packages here to produce fresh binaries

Background information while debugging this

- `dpkg --search /lib64/ld-linux-x86-64.so.2` to find out that the loader was provided by `libc6`.  It seems from the source code `elf/dl-version.c:match_symbol` that the warning message should not hurt much as long as the binaries themselves are compatible with each other
- `objdump -p /usr/bin/curl` to find out provides and version references from *p*rivate headers (headers that are binary format specific)
- `--version-script` is the linker option for producing dynamic libraries with versioned symbols
- OpenSSL packaged by Debian is patched with `debian/patches/version-script.patch` to provide versioned symbols
- Curl packaged by Debian is configured with `--enable-versioned-symbols`

## Background

There are times when we want to build packages from source for reasons like

1. The one provided by the distribution is old, has bugs, lacks the features.
	- QEMU, Vim, tmux, nginx, protobuf, openvswitch belong to this category
2. Or the distribution in concern does not provide it at all
	- ag (the_silver_searcher), crosstool-ng, mausezahn, libcli, mosh, openrestry, tengine are of this type
3. We want the process of `wget`, `configure`, `make`, `make install` to be automatic or at least semi-automatic.
	- Just specify the package name, version, url location, and optionally the MD5SUM of the source code, then viola.
4. We need to do customizations and want to make the process easily repeatable/reproducible at a later time
	- QEMU, nginx, vim are of this type
5. We want the effect/result of the build to be local without requiring root privileges or polutting the system directories
	- These packages will by default install to `$HOME/.usr` (the `--prefix` option)

The idea is not new, yet the result is rewarding.

Build scripts here uses the naming convention from OpenWrt package `Makefile`.

## TODO

- reinstall by copying and overwrite would fail because of permission bits issues

	openssl, git, libguestfs, readline

- archive
- provides listing and uninstall

## Backup Mirror

- https://distfiles.macports.org/$PKG_NAME

