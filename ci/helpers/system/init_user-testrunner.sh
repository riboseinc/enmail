#!/bin/bash
set -ex

# Create user "testrunner", change password to "testrunner"
# (same as user name), and add to "sudo" group.
useradd --create-home -G sudo --skel /helpers/home_skeleton testrunner
echo testrunner:testrunner | chpasswd

# Don't ask for password when "testrunner" invokes "sudo"
# Normally, one should use visudo, but here it's okay...
echo "testrunner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
