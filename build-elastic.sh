#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# Refs
#
# - elasticsearch-guide, https://endymecy.gitbooks.io/elasticsearch-guide-chinese/content/getting-started/README.html
#
# Status "cat"
#
#	curl http://localhost:9200/_cat/health'?v'
#	curl http://localhost:9200/_cat/nodes'?v'
#
# Basic usage
#
#	curl http://localhost:9200/flyspray?pretty -XDELETE
#	curl http://localhost:9200/flyspray?pretty -XPUT -d '{
#		  "mappings": {
#			"issuecount": {
#			  "properties": {
#				"epoch": {
#				  "type": "date",
#				  "format": "epoch_second"
#				},
#				"count": {
#				  "type": "integer"
#				}
#			  }
#			}
#		  }
#		}'
#	# the formst of issues.data.json
#	#
#	#	{"index": {"_index": "flyspray", "_id": 1491891883}}
#	#	{"epoch": 1491891883, "count": 208}
#	#
#	curl http://localhost:9200/flyspray/issuecount/_bulk?pretty --data-binary @$HOME/issues.data.json
#	curl http://localhost:9200/flyspray/issuecount/1491891883'?pretty'
#
ES_VERSION=5.4.3
ES_SOURCE_URL_BASE="https://artifacts.elastic.co/downloads"

PKG_BUILD_DIR_BASENAME="elastic-$ES_VERSION"

#
# elasticsearch provides http api service by default on http://localhost:9200
#
# it should run up out of box with bin/elasticsearch
#
# config/ dir contains settings for the app as well as jvm
#
PKG_NAME=elastic
PKG_VERSION=$ES_VERSION
PKG_elasticsearch_NAME=elasticsearch
PKG_elasticsearch_SOURCE="$PKG_elasticsearch_NAME-$ES_VERSION.zip"
PKG_SOURCE="$PKG_elasticsearch_SOURCE"
PKG_SOURCE_URL="$ES_SOURCE_URL_BASE/$PKG_elasticsearch_NAME/$PKG_elasticsearch_SOURCE"
PKG_SOURCE_MD5SUM=05dcae6ad60226fbdd0f9057989a7a32
PKG_PLATFORM=linux

#
# kibana listens by default on http://localhost:5601
#
# set elasticsearch.url in config/kibana.yml, then bin/kibana
#
# it's written in nodejs
#
PKG_kibana_NAME=kibana
PKG_kibana_VERSION=$ES_VERSION
PKG_kibana_SOURCE="$PKG_kibana_NAME-$ES_VERSION-linux-x86_64.tar.gz"
PKG_kibana_SOURCE_URL="$ES_SOURCE_URL_BASE/$PKG_kibana_NAME/$PKG_kibana_SOURCE"
PKG_kibana_SOURCE_MD5SUM=7525955de4aa728214cf0b34f32bcc74

. "$PWD/env.sh"
STRIP=()

download_extra() {
	download_http "$PKG_kibana_SOURCE"	"$PKG_kibana_SOURCE_URL"		"$PKG_kibana_SOURCE_MD5SUM"
}

prepare() {
	local name
	local source

	mkdir -p "$PKG_BUILD_DIR"
	for name in \
			elasticsearch \
			kibana \
			; do
		eval source="\$PKG_${name}_SOURCE"
		unpack "$BASE_DL_DIR/$source" "$PKG_BUILD_DIR"
		mv "$PKG_BUILD_DIR/$(unpack_dirname "$source")" "$PKG_BUILD_DIR/$name"
	done
}

configure() {
	true
}

compile() {
	true
}

staging() {
	local staging="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local sd="$staging/$PKG_BUILD_DIR_BASENAME"

	mkdir -p "$sd"
	cpdir "$PKG_BUILD_DIR" "$sd"
}

install() {
	local staging="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local sd="$staging/$PKG_BUILD_DIR_BASENAME"
	local d="$INSTALL_PREFIX/$PKG_BUILD_DIR_BASENAME"

	mkdir -p "$d"
	cpdir "$sd" "$d"
}

install_post() {
	local d="$INSTALL_PREFIX/$PKG_BUILD_DIR_BASENAME"

	__errmsg "
To run

	$d/$PKG_elasticsearch_NAME/bin/$PKG_elasticsearch_NAME
	$d/$PKG_kibana_NAME/bin/$PKG_kibana_NAME
"
}
