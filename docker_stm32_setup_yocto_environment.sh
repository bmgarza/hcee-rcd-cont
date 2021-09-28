#!/bin/bash
set -e # Make sure the script stops running when we hit an error

# The environment variables for this script need to be setup in the docker run command before we get to this point
source layers/meta-st/scripts/envsetup.sh

bitbake-layers add-layer ../layers/meta-st/meta-hlio-rcd/

