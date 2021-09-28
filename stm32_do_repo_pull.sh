#!/bin/bash
set -e # Make sure the script stops running when we hit an error

# Make sure that we haven't already run the repo init command, we know this if the .repo directory has already been
#  created
if [ ! -d $PWD/.repo ]; then
    repo init -u EnovationExternal@vs-ssh.visualstudio.com:v3/EnovationExternal/HCEE/hlio-rcd-manifest
fi

repo sync
