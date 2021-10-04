#!/bin/bash

# NOTE: BMG (Oct. 01, 2021) This script is going to be run from the context of the root of the repository, so make sure
#  that all scripts are referenced with that in mind

# The environment variables for this script need to be setup in the docker run command before we get to this point
source layers/meta-st/scripts/envsetup.sh < <(yes)

# NOTE: BMG (Oct. 01, 2021) There is a bug in the envsetup.sh script that incorrectly writes the SSTATE_MIRRORS
#  configuration for bitbake which was previously causing the url to not be correctly respected and the cache to not be
#  downloaded
sed -i 's#file:\/\/\\\.\\\*#file:\/\/\.\*#g' conf/site.conf 

bitbake-layers add-layer ../layers/meta-st/meta-hlio-rcd/
