GOROOT_FINAL="$INSTALL_PREFIX/go/goroot-$PKG_VERSION"

prepare_extra() {
	mv "$BASE_BUILD_DIR/go" "$PKG_BUILD_DIR"
}

configure() {
	true
}

compile() {
	cd "$PKG_BUILD_DIR"

	cd src/
	GOROOT_FINAL="$GOROOT_FINAL" \
		GOROOT_BOOTSTRAP="$GOROOT_BOOTSTRAP" \
		./all.bash
}

staging() {
	cp "$PKG_BUILD_DIR" "$PKG_STAGING_DIR"
}

install() {
	mkdir -p "$GOROOT_FINAL"
	cp "$PKG_STAGING_DIR" "$GOROOT_FINAL"
}

do_patch_common() {

	# os/exec: TestNohup fails inside tmux, https://github.com/golang/go/issues/5135
	patch -p1 <<"EOF"
From acb47657096a728d10b33f2949b5a52ef5226b9d Mon Sep 17 00:00:00 2001
From: Aaron Jacobs <jacobsa@google.com>
Date: Tue, 25 Aug 2015 08:53:42 +1000
Subject: [PATCH] os/signal: skip the nohup test on darwin when running in
 tmux.

The nohup command doesn't work in tmux on darwin.

Fixes #5135.

Change-Id: I1c21073d8bd54b49dd6b0bad86ef088d6d8e7a5f
Reviewed-on: https://go-review.googlesource.com/13883
Reviewed-by: Brad Fitzpatrick <bradfitz@golang.org>
---
 src/os/signal/signal_test.go | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/src/os/signal/signal_test.go b/src/os/signal/signal_test.go
index a71633c..7942e78 100644
--- a/src/os/signal/signal_test.go
+++ b/src/os/signal/signal_test.go
@@ -255,6 +255,12 @@ func TestNohup(t *testing.T) {
 
 	Stop(c)
 
+	// Skip the nohup test below when running in tmux on darwin, since nohup
+	// doesn't work correctly there. See issue #5135.
+	if runtime.GOOS == "darwin" && os.Getenv("TMUX") != "" {
+		t.Skip("Skipping nohup test due to running in tmux on darwin")
+	}
+
 	// Again, this time with nohup, assuming we can find it.
 	_, err := os.Stat("/usr/bin/nohup")
 	if err != nil {
EOF
}

do_patch_go14() {
	patch -p1 <<"EOF"
From 4890699929da4d76a6b237cfce36e2d5b1bb1460 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Thu, 31 Dec 2015 21:36:27 +0800
Subject: [PATCH] backport: runtime: initialize extra M for cgo during mstart

backport from go1.5 "b8caed8 runtime: initialize extra M for cgo during
mstart"
---
 src/runtime/cgocall.go  | 5 -----
 src/runtime/proc.c      | 7 ++++++-
 src/runtime/sigqueue.go | 9 ---------
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/src/runtime/cgocall.go b/src/runtime/cgocall.go
index 7fd9146..490e129 100644
--- a/src/runtime/cgocall.go
+++ b/src/runtime/cgocall.go
@@ -101,11 +101,6 @@ func cgocall_errno(fn, arg unsafe.Pointer) int32 {
 		racereleasemerge(unsafe.Pointer(&racecgosync))
 	}
 
-	// Create an extra M for callbacks on threads not created by Go on first cgo call.
-	if needextram == 1 && cas(&needextram, 1, 0) {
-		onM(newextram)
-	}
-
 	/*
 	 * Lock g to m to ensure we stay on the same stack if we do a
 	 * cgo callback. Add entry to defer stack in case of panic.
diff --git a/src/runtime/proc.c b/src/runtime/proc.c
index 8462c4b..34adae7 100644
--- a/src/runtime/proc.c
+++ b/src/runtime/proc.c
@@ -852,8 +852,13 @@ mstart(void)
 
 	// Install signal handlers; after minit so that minit can
 	// prepare the thread to be able to handle the signals.
-	if(g->m == &runtime·m0)
+	if(g->m == &runtime·m0) {
+		if(runtime·needextram) {
+			runtime·needextram = 0;
+			runtime·newextram();
+		}
 		runtime·initsig();
+	}
 	
 	if(g->m->mstartfn)
 		g->m->mstartfn();
diff --git a/src/runtime/sigqueue.go b/src/runtime/sigqueue.go
index fed4560..2d9c24d 100644
--- a/src/runtime/sigqueue.go
+++ b/src/runtime/sigqueue.go
@@ -154,15 +154,6 @@ func signal_disable(s uint32) {
 // This runs on a foreign stack, without an m or a g.  No stack split.
 //go:nosplit
 func badsignal(sig uintptr) {
-	// Some external libraries, for example, OpenBLAS, create worker threads in
-	// a global constructor. If we're doing cpu profiling, and the SIGPROF signal
-	// comes to one of the foreign threads before we make our first cgo call, the
-	// call to cgocallback below will bring down the whole process.
-	// It's better to miss a few SIGPROF signals than to abort in this case.
-	// See http://golang.org/issue/9456.
-	if _SIGPROF != 0 && sig == _SIGPROF && needextram != 0 {
-		return
-	}
 	cgocallback(unsafe.Pointer(funcPC(sigsend)), noescape(unsafe.Pointer(&sig)), unsafe.Sizeof(sig))
 }
 
-- 
2.6.4
EOF
}

do_patch() {
	cd "$PKG_BUILD_DIR"

	do_patch_common
	if [ "$PKG_NAME" = "go1.4" ]; then
		do_patch_go14
	fi
}
