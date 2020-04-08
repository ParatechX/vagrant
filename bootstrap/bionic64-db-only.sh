#!/usr/bin/env bash

###################################################################################
###                                                                   		 	###
### 	 Shell script to install packages, configure, import configuration	 	###
### 	 and manage services for a single box standard web lamp stack     	 	###
### 	 running Ubuntu Bionic 													###
###                                                                   		 	###
###################################################################################

# Params - see Vagrantfile for args order!
###################################################################################

PATH_WEB=$1 # default: "/var/www/html"
PATH_VAGRANT=$2 # default: "/var/vagrant"
PATH_SSH=$3 # default: "/home/vagrant/ssh"

# More path definitions
###################################################################################
PATH_HOME="/home/vagrant"
PATH_HTTP="/etc/apache2"
PATH_PHP="/etc/php/7.2"

# import useful functions (so they can be shared in different bootstrap scripts)
source "$PATH_VAGRANT/helpers/tools.sh"

###################################################################################
echo " # 0. Upgrading Packages..."
###################################################################################

# silence the stdin errors?
export DEBIAN_FRONTEND=noninteractive

# get the latest packages
sudo apt-get update -y
sudo apt-get upgrade -y

###################################################################################
echo " # 1. Installing Packages..."
###################################################################################
sudo apt-get install -y mysql-client-5.7
sudo apt-get install -y mysql-server-5.7

# a basic account for doing all
DBUSER="vagrant"
PASSWORD=$DBUSER
DOMAIN="%"
echo "Setting up db admin: $DBUSER / $PASSWORD / $DOMAIN"
setupSqlAdminUser $DBUSER $PASSWORD $DOMAIN

# todo -- revisit root user setup if time permits

###################################################################################
echo " # 2. Copying Files..."
###################################################################################

# Aliases
addLineOnce ". ~/.bash_aliases" "$PATH_HOME/.bashrc"
addLineOnce ". ~/.bash_env_vars" "$PATH_HOME/.bashrc"

cp $PATH_VAGRANT/bash_aliases $PATH_HOME/.bash_aliases
cp $PATH_VAGRANT/bash_env_vars $PATH_HOME/.bash_env_vars

# TODO -- would be nice to add phpmyadmin to this?

# make something cool?
# /etc/mysql/mysql.cnf

###################################################################################
echo " # 3. Customizing machine..."
###################################################################################

loadBoxCustomizersFromDirectory "$PATH_VAGRANT/post-provisions/"
loadBoxCustomizersFromDirectory "$PATH_VAGRANT/post-provisions/bionic-db-only/"

###################################################################################
# eof
