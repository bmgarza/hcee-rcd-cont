environment=$1

case $environment in
    "eglfs") environment_file="./docker_stm32_openstlinux_eglfs.env" ;;
    "weston") environment_file="./docker_stm32_openstlinux_weston.env" ;;
    "x11") environment_file="./docker_stm32_openstlinux_x11.env" ;;
    *) echo "First argument isn't a valid environment to build"; exit ;;
esac

command=$2
do_make=0

case $command in
    "make" | "build") do_make=1 ;;
    "") ;;
    *) echo "Second argument isn't a valid command for the build"; exit ;;
esac

container_name="yocto-build-cont"

if [[ "$do_make" -eq 1 ]]; then
    docker run --rm -it                                     \
        --name $container_name                              \
        --env-file $environment_file                        \
        -v $PWD:/tmp                                        \
        -w /tmp                                             \
        yocto-build bash -c "./docker_stm32_run_hlio_build.sh"
else
    docker run --rm -it                                     \
        --name $container_name                              \
        --env-file $environment_file                        \
        -v $PWD:/tmp                                        \
        -w /tmp                                             \
        yocto-build bash --init-file "./docker_stm32_setup_yocto_environment.sh"
fi
