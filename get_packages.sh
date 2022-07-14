apt update
apt -y install curl wget git gcc g++ cmake libssl-dev
./git-repo-build-and-install.sh cmake https://github.com/Kitware/CMake.git release
