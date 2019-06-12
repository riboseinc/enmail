#!/bin/bash
set -ex

# Install RVM and add testrunner to rvm group
curl -sSL https://get.rvm.io | bash
usermod -a -G rvm testrunner
