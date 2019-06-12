#!/bin/bash
set -ex

# CMake
# One could simply install cmake3 package, but it provides version too old for
# me.
curl --remote-name https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz
#wget https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz
tar -xvf cmake-3.12.0-Linux-x86_64.tar.gz
cp -r cmake-3.12.0-Linux-x86_64/bin /usr/
cp -r cmake-3.12.0-Linux-x86_64/share /usr/
cp -r cmake-3.12.0-Linux-x86_64/doc /usr/share/
cp -r cmake-3.12.0-Linux-x86_64/man /usr/share/

# Nevertheless, if you don't mind that, you can replace above lines with:
# apt-get install -y cmake3
