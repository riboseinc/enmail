#!/bin/bash
set -ex

apt-get update

# If you want custom PPAs, you need following.
apt-get install -y software-properties-common

# Build Essential is a collection of compilers and build tools.
# Git is obligatory for obvious reasons.
# bzip2 provides bzip2
# cURL is necessary to download RVM.
# Make is optional, and RVM installs it anyway, but I prefer to have it early on
# Sudo is sudo…
# Vim is optional, but I really love it.
apt-get install -y build-essential bzip2 curl git make sudo vim


apt-get install -y autoconf gcc g++ libbz2-dev libncurses5-dev libtool python wget zlib1g-dev
