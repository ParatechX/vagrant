#!/usr/bin/env bash

# upgrade system to the latest node lts 

# install the base packages
sudo apt-get -y install nodejs
sudo apt-get -y install npm

# show current versions
node -v
npm -v

# install latest npm
sudo npm install npm@latest -g

# leaving this for visual verify that it is the correct version
npm -v

# install the nodejs updater
sudo npm install -g n

# long term support
n lts

# alternative options
# n latest
# n stable
