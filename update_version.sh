#!/bin/bash

#export NODE_RED_VERSION=`grep -Eo "\"node-red\": \"(\w*.\w*.\w*)" package.json | cut -d\" -f4`
#echo $NODE_RED_VERSION

export NODE_RED_HOMEKIT_VERSION=`grep -Eo "\"node-red-contrib-homekit-bridged\": \"\^(\w*.\w*.\w*)" package.json | cut -d"^" -f2`
echo $NODE_RED_HOMEKIT_VERSION
