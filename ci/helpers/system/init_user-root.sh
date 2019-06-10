#!/bin/bash
set -ex

# Initialize root user's configs from homedir skeleton
cp -RT /helpers/home_skeleton /root
chown -R root root
