#!/bin/bash

set -e
set -x

BIN=/usr/bin/emacs24-x

for i in /bin/sh $BIN `ldd $BIN | sed -e 's/.*=>//g' -e 's/(.*//g' -e 's/^[ \t]*//g' | grep lib` ;do
  mkdir -p root/`dirname $i`
  cp -L $i root/`dirname $i`
done

mkdir -p root/usr/lib/emacs/24.3 
cp -a /usr/lib/emacs/24.3 root/usr/lib/emacs
mkdir -p root/usr/share/emacs
cp -a /usr/share/emacs/24.3 root/usr/share/emacs
cp -a /lib/terminfo root/lib

tar cC root . | docker import - emacs-box:latest

