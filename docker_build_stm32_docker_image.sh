#!/bin/bash

# Make sure that we go to the root of the repository to run this script
git_toplevel_path=$(git rev-parse --show-toplevel)
if [[ $git_toplevel_path == *"hcee-rcd-cont"* ]]; then
    # At this point we are sure that we are running this bash script from the correct repository
    if [[ $git_toplevel_path == *"yocto-dockerfiles"* ]]; then
        # We are within the yocto-dockerfiles directory, take that into account
        cd $git_toplevel_path/..
    else
        cd $git_toplevel_path
    fi
else
    echo "This command MUST be run from within the hcee-rcd-cont repository directory"
    exit 1 # Exit with an error code so that the rest of this script does run
fi

if [ ! -f $PWD/yocto-dockerfiles/README.md ]; then
    # If the README.md file for the yocto-dockerfiles repository doesn't exist, it's because the submodule hasn't been
    #  initialized yet. Run the command to initialize the submodules
    git submodule update --init
fi

# At this point now we know that the submodule has been properly initialized and that we are in the root of the
#  repository
cd yocto-dockerfiles/
docker build -t yocto-build -f dockerfiles/ubuntu/ubuntu-20.04/ubuntu-20.04-base/Dockerfile .
