#!/bin/bash

set -e
set -x

ldd /bin/sh > depends
ldd /bin/echo >> depends
ldd /bin/nc >> depends
ldd /bin/sleep >> depends
ldd ./flared >> depends
ldd ./flarei >> depends

NSS="
/lib/x86_64-linux-gnu/libbsd.so.0
/lib/x86_64-linux-gnu/libresolv.so.2
/etc/nsswitch.conf
/lib/x86_64-linux-gnu/libnss_files.so.2
/etc/services
"

for i in /bin/sh $NSS `cat depends | sed -e 's/.*=>//g' -e 's/(.*//g' -e 's/^[ \t]*//g' | grep lib` ;do
  mkdir -p root/`dirname $i`
  cp -L $i root/`dirname $i`
done

mkdir -p root/usr/bin
cp -L flared root/usr/bin
cp -L flarei root/usr/bin
cp -L run root/usr/bin
cp -L /bin/echo root/bin
cp -L /bin/nc root/bin
cp -L /bin/sleep root/bin

mkdir -p root/etc
cp -L flared.conf root/etc
cp -L flarei.conf root/etc

mkdir -p root/tmp

tar cC root . | docker import -c "CMD /usr/bin/run" - flare-box:latest
