#!/bin/bash

# The environment variables for this script need to be setup in the docker run command before we get to this point
source docker_stm32_setup_yocto_environment.sh

bitbake hlio-image-rcd
