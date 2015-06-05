#!/bin/bash

set -e
set -x

BIN=hello

GCONVS="
/usr/lib/x86_64-linux-gnu/gconv/UTF-16.so
/usr/lib/x86_64-linux-gnu/gconv/UTF-32.so
/usr/lib/x86_64-linux-gnu/gconv/UTF-7.so
/usr/lib/x86_64-linux-gnu/gconv/gconv-modules
/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache
"

rm -rf root

for i in /bin/sh $GCONVS `ldd $BIN | sed -e 's/.*=>//g' -e 's/(.*//g' -e 's/^[ \t]*//g' | grep lib` ;do
  mkdir -p root/`dirname $i`
  cp -L $i root/`dirname $i`
done

mkdir -p root/usr/bin
cp -L $BIN root/usr/bin


#mkdir -p root/usr/lib/x86_64-linux-gnu
#cp -a /usr/lib/x86_64-linux-gnu/gconv root/usr/lib/x86_64-linux-gnu

tar cC root . | docker import -c "CMD /usr/bin/hello" - hello:latest

