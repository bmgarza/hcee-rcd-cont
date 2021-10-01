#!/bin/bash
set -e # Make sure the script stops executing whenever we run into an error

does_group_exist() {
    group=$1
    grep --quiet $group /etc/group
}

get_group_of_file_or_dir() {
    path_to_dir=$1
    # This stat command only prints out the group of the directory
    stat -c "%G" $path_to_dir 2> /dev/null
}

get_user_of_file_or_dir() {
    path_to_dir=$1
    # This stat command only prints out the user of the directory
    stat -c "%U" $path_to_dir 2> /dev/null
}

stm32_dev_group_name="stm32-dev"
stm32_dev_directory_path="/stm32-dev"

################################################################################
## Setup the directory to contain all the stm32 development stuff             ##
################################################################################
# Check to see if the stm32-dev exists, if it doesn't then make sure that we create the group
if ! does_group_exist $stm32_dev_group_name; then
    echo "The stm32-dev group doesn't exist, adding it now"
    sudo groupadd stm32-dev
    echo ""
fi

# If the stm32 development directory doesn't exist, we want to make sure we create it before we continue
if [ ! -d $stm32_dev_directory_path ]; then
    echo "The stm32-dev directory doesn't exist, making it now"
    sudo mkdir $stm32_dev_directory_path
    echo ""
fi

# If the stm32 development directory isn't assigned to the correct group, make sure we fix that assignment so that
#  everyone can access the directory
if [[ $(get_group_of_file_or_dir $stm32_dev_directory_path) != $stm32_dev_group_name ]]; then
    echo "The stm32-dev directory isn't assigned to the correct group, fixing the assignment"
    sudo chgrp -R $stm32_dev_group_name $stm32_dev_directory_path
    echo ""
fi

# Make sure that the permissions on the directory are set so that the group has all the permissions
sudo chmod --recursive 774 $stm32_dev_directory_path
