#!/bin/bash

help_dialog() {
    echo "run_docker_stm32.sh <ENVIRONMENT> <COMMAND>"
    echo "    ENVIRONMENT => weston | eglfs | x11 | clean"
    echo "    COMMAND => make | build | noargs | \"\""
    echo ""
}

clean_bitbake() {
    echo "Cleaning the remnants of the bitbake server"
    rm -r PRServer_127.0.0.1_*
}

ensure_directory() {
    directory_path=$1

    if [ ! -d $directory_path ]; then
        echo "The directory ($directory_path) does not exist, creating it now."
        mkdir $directory_path
    fi
}

run_docker_container() {
    docker run --rm -it                                     \
        --name $container_name                              \
        --env FORCE_SSTATE_CACHEPREFIX=$container_home_dir  \
        --env-file $environment_file_default                \
        --env-file $environment_file                        \
        -v $PWD:$container_home_dir                         \
        -w $container_home_dir                              \
        yocto-build $@
}

################################################################################
## Main portion of the function                                               ##
################################################################################

# This is going to make it such that we can only run this script from the same directory. Well... Really it's only going
#  to allow the script to run from directories that contain a script of the same name, but it's really unlikely that
#  happens in somewhere other than the same directory this script lives in. This portion of code can be placed basically
#  anywhere
if ! $(grep --quiet -x $(basename $0) < <(ls)); then
    echo "This script must be run from the directory where it exists"
    exit 1
fi

# Arguments that were passed through to the script
environment=$1
command=$2

container_name="yocto-build-cont"
environment_file_default="./docker_stm32_openstlinux_default.env"
container_home_dir="/tmp"

# Make sure that we set the correct environment variables for the build environment that we want
case $environment in
    "eglfs") environment_file="./docker_stm32_openstlinux_eglfs.env" ;;
    "weston") environment_file="./docker_stm32_openstlinux_weston.env" ;;
    "x11") environment_file="./docker_stm32_openstlinux_x11.env" ;;
    # TODO: BMG (Sep. 30, 2021) This is probably not the right way to do this... Might want to change the order of the
    #  arguments that so the command comes first and the environment comes second
    "clean") clean_bitbake; exit ;;
    "") help_dialog; exit;;
    *) echo "First argument isn't a valid environment to build"; exit ;;
esac

# Run the correct docker run command based on what the argument that was passed through to this script is
case $command in
    # TODO: BMG (Sep. 30, 2021) There has to be a better way of doing this, haven't put in enough time to figure out how
    #  to do this in a cleaner way
    "make" | "build")
        # Runs a script to go through and do a build automatically
        run_docker_container bash -c "./docker_stm32_run_hlio_build.sh"
        ;;
    "noargs")
        # Just runs the docker container without setting up the environment or anything. Mainly for running the
        #  envsetup.sh command and debugging some of those tools
        run_docker_container bash
        ;;
    "")
        # Runs a script to setup the bitbake environment so that you can run individual bitbake commands immediately
        run_docker_container bash --init-file "./docker_stm32_setup_yocto_environment.sh"
        ;;
    *) echo "Second argument isn't a valid command for the build"; exit ;;
esac

# Clean up after the bitbake environment has been setup
clean_bitbake
