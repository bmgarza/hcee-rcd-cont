#!/bin/bash
set -e # Make sure the script stops running when we hit an error

# This is going to make it such that we can only run this script from the same directory. Well... Really it's only going
#  to allow the script to run from directories that contain a script of the same name, but it's really unlikely that
#  happens in somewhere other than the same directory this script lives in. This portion of code can be placed basically
#  anywhere
if ! $(grep --quiet -x $(basename $0) < <(ls)); then
    echo "This script must be run from the directory where it exists"
    exit 1
fi

# Make sure that we haven't already run the repo init command, we know this if the .repo directory has already been
#  created
if [ ! -d $PWD/.repo ]; then
    repo init -u EnovationExternal@vs-ssh.visualstudio.com:v3/EnovationExternal/HCEE/hlio-rcd-manifest
fi

repo sync
