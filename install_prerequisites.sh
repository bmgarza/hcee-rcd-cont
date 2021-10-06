
# Install Repo
# Make sure python-is-python3 is installed for Repo to work correctly
sudo apt install python-is-python3
export REPO=$(mktemp /tmp/repo.XXXXXXXXX)
# Pull Repo from its google download location
curl -o ${REPO} https://storage.googleapis.com/git-repo-downloads/repo
# Add a gpg key to verify the repo download
gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 8BB9AD793E8E6153AF0F9A4416530D5E920F5C65
# Make a bin directory for the current user
mkdir ~/bin
# Pull the gpg keys and verify them
curl -s https://storage.googleapis.com/git-repo-downloads/repo.asc | gpg --verify - ${REPO} && install -m 755 ${REPO} ~/bin/repo

# Pull the docker install convenience script and run it
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# Put the current user in the Docker group to make sure they can use it without the need to use sudo
sudo usermod -aG docker $UID

echo "You might need to log out and log back in to make sure that the addition of the user to the docker group is"
echo "properly working. This is necessary to avoid having to run the docker command through sudo"
