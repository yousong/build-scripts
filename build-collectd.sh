#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=collectd
PKG_VERSION=5.9.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://github.com/collectd/collectd/releases/download/$PKG_NAME-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=84fbc1940b90ad34c10870c3187d7022
PKG_DEPENDS='libiconv liboping LuaJIT ncurses python2 python3'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-silent-rules
)

if false; then
	# https://github.com/google/sanitizers/wiki/AddressSanitizerCallStack
	# export ASAN_SYMBOLIZER_PATH=/home/yunion/.usr/toolchain/llvm-8.0.1/bin/llvm-symbolizer
	env_init_llvm_toolchain
	EXTRA_CFLAGS+=(
		-fno-omit-frame-pointer
		-fsanitize=address
		-g
	)
	CONFIGURE_ARGS+=(
		--enable-debug
	)
fi

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
From 219d4eb33e280e2c8d5a590a529af054638d986a Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Mon, 14 Oct 2019 06:48:56 +0000
Subject: [PATCH 1/2] exec: free up memory on shutdown

---
 src/exec.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/src/exec.c b/src/exec.c
index 7e161677..965a8443 100644
--- a/src/exec.c
+++ b/src/exec.c
@@ -918,6 +918,11 @@ static int exec_shutdown(void) /* {{{ */
       INFO("exec plugin: Sent SIGTERM to %hu", (unsigned short int)pl->pid);
     }
 
+    for (int i = 0; pl->argv[i] != NULL; i++) {
+      sfree(pl->argv[i]);
+    }
+    sfree(pl->argv);
+    sfree(pl->exec);
     sfree(pl->user);
     sfree(pl);

EOF

	patch -p1 <<"EOF"
From 38dadfde6099855bcf5cf6b975ff79b8fcad6397 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <zhouyousong@yunionyun.com>
Date: Tue, 15 Oct 2019 02:48:32 +0000
Subject: [PATCH 2/2] network: fix data race when accessing sending_sockets

This can happen with more than 1 WriteThreads
---
 src/network.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/src/network.c b/src/network.c
index f6f0ac15..f4c7f1f9 100644
--- a/src/network.c
+++ b/src/network.c
@@ -142,6 +142,7 @@ typedef struct sockent {
   } data;
 
   struct sockent *next;
+  pthread_mutex_t lock;
 } sockent_t;
 
 /*                      1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3
@@ -1540,6 +1541,7 @@ static void sockent_destroy(sockent_t *se) /* {{{ */
 
     sfree(se->node);
     sfree(se->service);
+    pthread_mutex_destroy(&se->lock);
 
     if (se->type == SOCKENT_TYPE_CLIENT)
       free_sockent_client(&se->data.client);
@@ -1858,6 +1860,7 @@ static sockent_t *sockent_create(int type) /* {{{ */
   se->service = NULL;
   se->interface = 0;
   se->next = NULL;
+  pthread_mutex_init(&se->lock, NULL);
 
   if (type == SOCKENT_TYPE_SERVER) {
     se->data.server.fd = NULL;
@@ -1949,6 +1952,8 @@ static int sockent_client_disconnect(sockent_t *se) /* {{{ */
     client->fd = -1;
   }
 
+  DEBUG("network plugin: free (se = %p, addr = %p);", (void *)se,
+        (void *)client->addr);
   sfree(client->addr);
   client->addrlen = 0;
 
@@ -2020,6 +2025,8 @@ static int sockent_client_connect(sockent_t *se) /* {{{ */
       client->fd = -1;
       continue;
     }
+    DEBUG("network plugin: alloc (se = %p, addr = %p);", (void *)se,
+          (void *)client->addr);
 
     assert(sizeof(*client->addr) >= ai_ptr->ai_addrlen);
     memcpy(client->addr, ai_ptr->ai_addr, ai_ptr->ai_addrlen);
@@ -2541,6 +2548,7 @@ static void network_send_buffer(char *buffer, size_t buffer_len) /* {{{ */
         buffer_len);
 
   for (sockent_t *se = sending_sockets; se != NULL; se = se->next) {
+    pthread_mutex_lock(&se->lock);
 #if HAVE_GCRYPT_H
     if (se->data.client.security_level == SECURITY_LEVEL_ENCRYPT)
       network_send_buffer_encrypted(se, buffer, buffer_len);
@@ -2549,6 +2557,7 @@ static void network_send_buffer(char *buffer, size_t buffer_len) /* {{{ */
     else /* if (se->data.client.security_level == SECURITY_LEVEL_NONE) */
 #endif   /* HAVE_GCRYPT_H */
       network_send_buffer_plain(se, buffer, buffer_len);
+    pthread_mutex_unlock(&se->lock);
   } /* for (sending_sockets) */
 } /* }}} void network_send_buffer */
 
EOF
}
