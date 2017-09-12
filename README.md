Scripts for quickly building/installing specified version of open source projects from source code to specified location.

- Edit settings in `env.sh` before using this
- These scripts are not trying to be foolproof

	Previously experience with target projects and some shell scripting experience is expected

- Scripts are executed with `/bin/bash -e`
- Scripts are written in a way trying to be "reentrant"
- Use absolute path

## Prerequisites

	GNU wget
	GNU tar, command line option --transform support
	GNU gzip, BSD gunzip of at least El Capitan will exit with 1 when the archive was compressed with padded zeros
	patch
	uudecode, can be provided by debian package sharutils
	md5sum
	git
	make
	cmake
	autoconf
		- there are times we need to patch configure.ac and regenerate configure script with autoreconf
		- json-c requires at least autoconf 2.68
	texinfo
		- gdb requires makeinfo to build info pages

- gzip complains with trailing garbage ignored, http://www.gzip.org/#faq8

### RHEL/CentOS 6

On RHEL/CentOS 6, the default toolchain is too old for building many packages of newest version.

1. Anonymous struct/union support of c11 standard is required from gcc to build luajit bundled with wrk.  GCC 4.4 does not work.
2. ruby of at least version 1.9 is required to build mruby bundled with h2o
3. Some packages requires newer versions of autoconf and pkg.m4 from pkg-config
4. QEMU 2.5 requires g++ with flag `-fstack-protector-strong` which is not available in the 4.4 line

The solution at the moment is to use newer toolchain from [Software Collections](https://www.softwarecollections.org/) service before we can build toolchains by ourself

	# Install base packages
	yum install scl-utils
	yum install centos-release-scl-rh

	# GCC 4.9 from devtoolset, - https://www.softwarecollections.org/en/scls/rhscl/devtoolset-3/
	#
	# search what's available
	#
	#	yum search devtoolset-3
	yum install devtoolset-3-gcc devtoolset-3-gcc-c++ devtoolset-3-binutils

	# Ruby 2.2, https://www.softwarecollections.org/en/scls/rhscl/rh-ruby22/
	yum install rh-ruby22

	# Autotools
	# Try using Autotools in SCL at the moment, https://www.softwarecollections.org/en/scls/praiskup/autotools/

	# Use them within a shell
	scl enable devtoolset-3 rh-ruby22 autotools-latest zsh

## How to use this

Packages built will be installed to `$INSTALL_PREFIX`, which is `$HOME/.usr/`
at the moment.  Directory locations can be customized by editing `env.sh`

Just setting `PATH` should be enough to use the built binaries as these
packages are to be compiled with `-rpath` support which means that there is no
need to set `LD_LIBRARY_PATH` or `DYLD_LIBRARY_PATH`.

Steps to setup environment variables to use the built binaries

	# Use installed binaries
	export PATH=$INSTALL_PREFIX/bin:$INSTALL_PREFIX/sbin:$PATH

	# Use installed manpages
	MANPATH="$INSTALL_PREFIX/share/man:$(manpath)"

Compile one by one and handle dependencies by mind

	# download, prepare, configure, compile, staging
	./build-nginx-vanilla.sh till staging

	# single action configure
	./build-nginx-vanilla.sh configure

	# remove build_dir/nginx-1.9.9
	./build-nginx-vanilla.sh clean

	# uninstall based on dest_dir/nginx-1.9.9-install
	./build-nginx-vanilla.sh uninstall

Compile with `Makefile`

	# download, prepare, configure, compile, staging
	make nginx/staging

	# same but happens in tests_dir/
	make nginx/staging/test

	# do them all
	make download
	make staging
	make install/test

## Tips

Packages can depend on the installation of other packages to be successfully
built and run.  We can use system's package manager to help us for packages not
provided here.

	apt-get install build-essential
	apt-get build-dep openvpn
	apt-cache showsrc openvpn | grep Build-Depends

	yum -y groupinstall "Development Tools"
	yum-builddep openvpn

## FAQ

### `sudo: flowtop: command not found`

Most of the time `sudo` will use a predefined `PATH` for its child processes,
so binaries not in that directory list cannot be found.

There are a few methods to work around this

1. Use absolute path

		sudo `which flowtop` -h

2. Edit `sudoers` setting with `visudo`.  See sudoers manual for syntax details

		# keep PATH for user yousong: replace the default Defaults settings for
		# secure_path
		Defaults:  yousong env_keep += "PATH"
		Defaults: !yousong secure_path = /sbin:/bin:/usr/sbin:/usr/bin

### Versioned symbols

On Debian, Warning messages like the following can be emitted by dynamic linker

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

I want to build packages from source for reasons like

1. The one provided by the distribution is old, has bugs, lacks the features we want.
	- QEMU, Vim, tmux, nginx, protobuf, openvswitch belong to this category
2. Or the distribution does not provide it at all
	- ag (the_silver_searcher), crosstool-ng, mausezahn, libcli, mosh, openrestry, tengine are of this type
3. I want the process of `wget`, `tar xzf`, patching, `configure`, `make`, `make install` to be automatic or at least semi-automatic.
	- We can make it a "viola" thing when we need to do it again
4. I want to do customizations and want to make the process easily repeatable/reproducible at a later time
	- QEMU, nginx, vim are of this type
5. We want the effect/result of the build to be local without requiring root privileges or polutting the system directories
	- No, `/usr/local` is not an option

The idea is not new, yet the result is rewarding.  Scripts here uses the naming
convention from OpenWrt package `Makefile`.

## TODO

- Build toolchain: binutils, linux-headers, libc, gcc

	- 5. Constructing a Temporary System, http://www.linuxfromscratch.org/lfs/view/stable/

- provide listing and uninstall
- archive

## Backup Mirror

- https://distfiles.macports.org/$PKG_NAME
