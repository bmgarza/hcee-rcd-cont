#!/bin/bash

# This is going to make it such that we can only run this script from the same directory. Well... Really it's only going
#  to allow the script to run from directories that contain a script of the same name, but it's really unlikely that
#  happens in somewhere other than the same directory this script lives in. This portion of code can be placed basically
#  anywhere
if ! $(grep --quiet -x $(basename $0) < <(ls)); then
    echo "This script must be run from the directory where it exists"
    exit 1
fi

# At this point now we know that the submodule has been properly initialized and that we are in the root of the
#  repository
cd yocto-dockerfiles/
docker build -t yocto-build -f dockerfiles/ubuntu/ubuntu-20.04/ubuntu-20.04-base/Dockerfile .
