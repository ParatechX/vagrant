#!/usr/bin/env bash

# give us more punch for those composer days
# https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-18-04/
echo "Setting up swapfile to boost composer memory."
sudo rm /swapfile
sudo fallocate -l 3G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

# call as needed with swapon/swapoff from terminal
# sudo swapon /swapfile
