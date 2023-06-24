#!/bin/bash

# Set the repository URL, destination directory, and specific folder
REPO_URL="https://github.com/HadarNeu/Kandula.git"
DEST_DIR="./Kandula"
SPECIFIC_FOLDER="ansible-playbooks"

# Set your Git username and access token 
# git token is environment variable!
GIT_USERNAME="hadarneu"
GIT_ACCESS_TOKEN=$GIT_ACCESS_TOKEN

git clone -n --depth=1 --filter=tree:0 $REPO_URL
cd $DEST_DIR
pwd
git sparse-checkout set --no-cone $SPECIFIC_FOLDER
git checkout


git config --global user.email "hadar@noylander@gmail.com"
git config --global user.name "hadarneu"

# git config --global user.email "hadar@noylander@gmail.com" && git config --global user.name "hadarneu"