#!/bin/bash
set -ex

# Create user "testrunner", change password to "testrunner"
# (same as user name), and add to "sudo" group
useradd --create-home testrunner --skel /helpers/home_skeleton
echo testrunner:testrunner | chpasswd
usermod -a -G sudo testrunner

# Don't ask for password when "testrunner" invokes "sudo"
# Normally, one should use visudo, but here it's okay...
echo "testrunner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
