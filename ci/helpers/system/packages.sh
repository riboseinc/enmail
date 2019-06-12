#!/bin/bash
set -ex

apt-get update

# If you want custom PPAs, you need following.
apt-get install -y software-properties-common

# Sudo is sudo…
apt-get install -y sudo

# Following are required build tools:
# Autoconf is required to build GnuPG and RNP from Git sources.
# Build Essential is a collection of compilers and build tools.
# bzip2 is required to unpack GnuPG source packages.
# CMake is required to build RNP.
# cURL is necessary to download RVM.
# Git is obligatory for obvious reasons.
# Libtool is required to build RNP from Git sources.
# Python is required to build Botan.
apt-get install -y autoconf build-essential bzip2 cmake curl git libtool python3

# Some GUI toolkit or framework is required to build GnuPG's Pinentry, and
# ncurses is the least demanding option.
apt-get install -y libncurses5-dev

# These are RNP dependencies
apt-get install -y libbz2-dev zlib1g-dev

# Vim is entirely optional, but I really love to have it.
apt-get install -y vim
