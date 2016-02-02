#!/bin/sh -e

PKG_NAME=perl
PKG_VERSION=5.22.1
PKG_SOURCE="perl-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.cpan.org/src/5.0/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=19295bbb775a3c36123161b9bf4892f1
#PKG_DEPENDS='bzip2 db openssl ncurses readline sqlite zlib'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	# taken from https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=782068
	patch -p1 <<"EOF"
From a8e8eea6bd2010db0191677174b5ca87058f3bf1 Mon Sep 17 00:00:00 2001
From: Niko Tyni <ntyni@debian.org>
Date: Fri, 10 Apr 2015 10:19:51 +0300
Subject: Make t/run/locale.t survive missing locales masked by LC_ALL

If LC_ALL is set to a valid locale but another LC_* setting like LC_CTYPE
isn't, t/run/locale.t would fail because it explicitly unsets LC_ALL,
unmasking the problem underneath. All the other tests survive such
a scenario.

While this is clearly an error in the build environment, it's easy to make
the test more robust by first clearing all the locale relevant variables.

Bug-Debian: https://bugs.debian.org/782068
---
 t/run/locale.t | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/t/run/locale.t b/t/run/locale.t
index 3483f02..ddf8382 100644
--- a/t/run/locale.t
+++ b/t/run/locale.t
@@ -27,6 +27,9 @@ my $have_strtod = $Config{d_strtod} eq 'define';
                                  ) };
 skip_all("no locales available") unless @locales;
 
+# reset the locale environment
+local @ENV{'LANG', (grep /^LC_/, keys %ENV)};
+
 plan tests => &last;
 
 my $non_C_locale;
@@ -58,9 +58,6 @@ EOF
 SKIP: {
     skip("Windows stores locale defaults in the registry", 1 )
                                                             if $^O eq 'MSWin32';
-    local $ENV{LC_NUMERIC}; # So not taken as a default
-    local $ENV{LC_ALL}; # so it never overrides LC_NUMERIC
-    local $ENV{LANG};   # So not taken as a default
     fresh_perl_is("for (qw(@locales)) {\n" . <<'EOF',
         use POSIX qw(locale_h);
         use locale;
@@ -260,7 +260,6 @@ EOF
 
     {
 	local $ENV{LC_NUMERIC} = $different;
-	local $ENV{LC_ALL}; # so it never overrides LC_NUMERIC
 	fresh_perl_is(<<'EOF', "$difference "x4, {},
             use locale;
 	    use POSIX qw(locale_h);
EOF
}

CONFIGURE_CMD=./Configure
# -d : use defaults for all answers.
# -e : go on without questioning past the production of config.sh.
# -s : silent mode, only echoes questions and essential information.
CONFIGURE_ARGS="					\\
	-des							\\
	-Dprefix='$INSTALL_PREFIX'		\\
	-Dcflags='$EXTRA_CFLAGS'		\\
	-Dldflags='$EXTRA_LDFLAGS'		\\
	-Dcppflags='$EXTRA_CPPFLAGS'	\\
	-Dusethreads					\\
	-Duseshrplibs					\\
"

staging_pre() {
	cd "$PKG_BUILD_DIR"
	$MAKEJ test
}
