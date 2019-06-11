#!/bin/bash
set -ex

# Create user "travis", change password to "travis" (same as user name),
# and add to "sudo" group
useradd --create-home travis --skel /helpers/home_skeleton
echo travis:travis | chpasswd
usermod -a -G sudo travis

# Don't ask for password when "travis" invokes "sudo"
# Normally, one should use visudo, but here it's okay...
echo "travis ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
