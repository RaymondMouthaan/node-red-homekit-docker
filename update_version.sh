#!/bin/bash
ls -al
export NODE_RED_VERSION=`grep -Eo "\"node-red\": \"(\w*.\w*.\w*)" ./package.json | cut -d\" -f4`
echo "node-red version: ${NODE_RED_VERSION}"
sed -i "" -e "s/\(version\": \"\).*\(\"\)/\1$NODE_RED_VERSION\"/g" ./package.json

export NODE_RED_HOMEKIT_VERSION=`grep -Eo "\"node-red-contrib-homekit-bridged\": \"\^(\w*.\w*.\w*)" ./package.json | cut -d"^" -f2`
echo "node-red-contrib-homekit-bridged version: ${NODE_RED_HOMEKIT_VERSION}"
