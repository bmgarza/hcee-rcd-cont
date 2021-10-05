# HCEE RCD Containing Directory

This repository serves as a repository that holds a number of scripts that simplify the setting up and use of the
development environment for the Real Cost Display.

## Prerequisites

The only prerequisite for using the scripts in this repository is having docker installed. Docker is going to be used to
house the image/environment that is used for setting up the environment and building everything that needs to be made.
This repository only contains shell scripts that are going to handle all the annoying parts of building for you.

## Getting set up

Getting started with development from this repository is as simple as running the following two scripts:

1. `stm32_do_repo_pull.sh`: This scirpt is going to make sure that repo pulls in all the repositories that we need in
                            order to get the environment building and working. Before this step is run you should
                            probably make sure that your have properly setup your ssh keys if that is how you want to
                            authenticate with the repository.
2. `run_docker_stm32.sh weston make`: This script sets up the docker image that is going to be used to setup the
                          environment and start the first build process. This is going to be the primary script that is
                          going to be run for building and working with the yocto build environment that we're building
                          with.

These are the basic steps to get everything setup for development, but the `run_docker_stm32.sh` script has more
functionality outside of just making that helps with using tools like devtools and other bitbake features so make sure
that you take a look at the help documentation for that script by calling it without any arguments.

### Getting set up without having to rebuild everything

There is a likely chance that you've already built the environment before you started using these scripts, in this case
there is something you can do to make sure that you don't have to recompile all of the other libraries that go into the
image that we are creating for the display.

In your previous build directory you will need to go in and move the contents of the
`<OLD_BUILD_DIR>/build-openstlinuxweston-stm32mp1/sstate-cache/` directory to this repository inside the
`<THIS_REPO>/oe-sstate-cache/` directory. With this done, the next time that you go to build the image it should
automatically pick up the cache and it shouldn't take very long for everything to be built. Additionally, maybe not now
but at some point, there is going to be a server that hosts a cache for the build process that should expedite the build
process by avoiding having the build the majority of the binaries.
