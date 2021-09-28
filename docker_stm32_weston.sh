docker run --rm -it                                     \
    -v $PWD/hcee_rcd:/tmp                               \
    -w /tmp                                             \
    --env-file ./docker_stm32_openstlinux_weston.env    \
    yocto-build:1.0 bash -c "source docker_stm32_setup_yocto_environment.sh"

