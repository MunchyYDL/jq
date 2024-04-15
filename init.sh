#!/usr/bin/env bash
set -e

prefix=prod
date=$(date +%F)

if [ ! -z "$1" ]; then
  prefix=$1
fi

dir="$prefix-$date" 
path=./reports/$dir

if [ ! -d $path ]; then
  # Create path
  cp -r ./reports/dev $path
fi

echo $path
