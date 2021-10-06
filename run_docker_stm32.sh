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

check_url_OK() {
    url_provided=$1

    grep "200 OK" --quiet < <(curl --silent --connect-timeout 1 --head $url_provided)
}

remove_special_chars() {
    string=$1

    echo "$string" | sed "s/-//g"
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

docker_image_name="yocto-build"
container_name="yocto-build-cont"
container_home_dir="/tmp"
sstate_cache_base_url="http://192.168.1.100"

# TODO: BMG (Oct. 04, 2021) This is currently not used but at some point we are going to set this variable based on
#  something to determine if we are a server node or not
is_server=0

docker_container_serve() {
    docker run --name "apache-serve-cache" --rm -dit -v $PWD:/usr/local/apache2/htdocs/ httpd
}

base_docker_container_cmd() {
    docker run --rm -it                                     \
        --name "$container_name-$environment"               \
        --env FORCE_SSTATE_MIRROR_URL=$sstate_cache_url     \
        --env-file $environment_file                        \
        --user "$UID"                                       \
        -v $PWD:$container_home_dir                         \
        -w $container_home_dir                              \
        $@
}

# NOTE: BMG (Oct. 04, 2021) This function isn't currently used but the idea is that it would use a different set of
#  environment variables or arguments whenever we are running in a server in case that is something that would be useful
server_docker_container_cmd() {
    base_docker_container_cmd \
        $@
}

run_docker_container() {
    if [ $is_server != 0 ]; then
        # We are currently operating on a server node
        server_docker_container_cmd \
            $docker_image_name $@
    else
        # We are not a server
        base_docker_container_cmd \
            $docker_image_name $@
    fi
}

# Make sure that we set the correct environment variables for the build environment that we want
case $environment in
    "sdk") environment_file="./docker/docker_stm32_openstlinux_sdk.env" ;;
    "display") environment_file="./docker/docker_stm32_openstlinux_display.env" ;;
    "legacy") environment_file="./docker/docker_stm32_openstlinux_legacy.env" ;;
    # TODO: BMG (Sep. 30, 2021) This is probably not the right way to do this... Might want to change the order of the
    #  arguments that so the command comes first and the environment comes second
    "clean") clean_bitbake; exit ;;
    "serve") docker_container_serve; exit ;;
    "" | "help" | "--help") help_dialog; exit;;
    *) echo "First argument isn't a valid environment to build"; exit ;;
esac

# Export the environment variables from the selected environment file
if [ -f "$environment_file" ]; then
    export $(cat $environment_file | xargs)
fi

# Generate the build directory name based on the Distro and Machine that we are building with
yocto_build_dir="build-$(remove_special_chars $DISTRO)-$(remove_special_chars $MACHINE)"

# Generate the url that the specific distro is going to use for pulling the sstate cache
sstate_cache_url="$sstate_cache_base_url/$yocto_build_dir/sstate-cache"

# Check to see if the url to pull the sstate cache is actually up and good to pull from, if it isn't disable it to
#  prevent a slowdown when compiling
if check_url_OK $sstate_cache_url && [ -f "./$yocto_build_dir/conf/site.conf" ]; then
    echo "SSTATE cache is good, enabling it"
    # Enable SSTATE_MIRRORS if server is accessible
    sed -i 's/^# SSTATE_MIRRORS/SSTATE_MIRRORS/g' "./$yocto_build_dir/conf/site.conf"
else
    echo "SSTATE cache not reachable, disabling it"
    # Disable SSTATE_MIRRORS if server is inaccesible
    sed -i 's/^SSTATE_MIRRORS/# SSTATE_MIRRORS/g' "./$yocto_build_dir/conf/site.conf"
fi

# Run the correct docker run command based on what the argument that was passed through to this script is
case $command in
    # TODO: BMG (Sep. 30, 2021) There has to be a better way of doing this, haven't put in enough time to figure out how
    #  to do this in a cleaner way
    "make" | "build")
        # Runs a script to go through and do a build automatically
        run_docker_container bash -c "./docker/docker_stm32_run_hlio_build.sh"
        # Clean up after the bitbake environment has been run
        clean_bitbake
        ;;
    "noargs")
        # Just runs the docker container without setting up the environment or anything. Mainly for running the
        #  envsetup.sh command and debugging some of those tools
        run_docker_container bash
        ;;
    "")
        # Runs a script to setup the bitbake environment so that you can run individual bitbake commands immediately
        run_docker_container bash --init-file "./docker/docker_stm32_setup_yocto_environment.sh"
        ;;
    *) echo "Second argument isn't a valid command for the build"; exit ;;
esac
