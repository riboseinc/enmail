#!/bin/bash
set -ex

# Install RVM and add travis to rvm group
curl -sSL https://get.rvm.io | bash
usermod -a -G rvm travis
