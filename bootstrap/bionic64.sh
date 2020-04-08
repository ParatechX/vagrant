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

PATH_VAGRANT=$1 # default: "/var/vagrant"
PATH_SSH=$2 # default: "/home/vagrant/ssh"
HOST_IP=10.0.2.2

# look here if you have trouble running Xdebug 
###################################################################################
XDEBUG_LOG_PATH="/tmp"

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

# get apache going
sudo apt-get install apache2 -y
sudo systemctl start apache2.service

# PHP setup  -- 7.2 -- specific
# NOTE: Not sure if specifying versions here is the right way to go. The repo
# may only store the latest so these could drop out. 

# a basic check to ensure the version is still in the distro
exitIfPackageIsMissing 'php7.2'

# check what is out there:
# apt-cache pkgnames | grep php7.2
sudo apt-get install -y php7.2

# todo -- do we actually need all those packages??
sudo apt-get install -y php7.2-{bcmath,bz2,intl,gd,mbstring,mysql,zip,fpm,xsl,curl,soap,tidy,sqlite3}
# left out from previous version: mcrypt, pear, pdo-mysql

# Misc PHP Packages
# not listed as 7.2 package but exists!
sudo apt-get install -y php-xdebug

# @todo -- is it still needed?
sudo apt-get install -y imagemagick

# composer/laravel will ask for this
sudo apt-get install -y zip unzip

# Git
sudo apt-get install -y git

# Composer
cd /tmp && curl -sS https://getcomposer.org/installer | php
sudo mv /tmp/composer.phar /usr/local/bin/composer

# MySQL-Client -- requires connection to host database if next line is commented out!
sudo apt-get install -y mysql-client-5.7
sudo apt-get install -y mysql-server-5.7

# cannot use supervisor to maintain the laravel queue worker
# run flock like so instead:
# flock -xn /tmp/laravel_queues.lockfile -c "/usr/bin/php /path/to/laravel/artisan queue:listen"

# a basic account for doing all
DBUSER="vagrant"
PASSWORD=$DBUSER
DOMAIN="%"
echo "Setting up db admin: $DBUSER / $PASSWORD / $DOMAIN"
setupSqlAdminUser $DBUSER $PASSWORD $DOMAIN

###################################################################################
echo " # 2. Copying Files..."
###################################################################################

# Aliases
addLineOnce ". ~/.bash_aliases" "$PATH_HOME/.bashrc"
addLineOnce ". ~/.bash_env_vars" "$PATH_HOME/.bashrc"

# bash tools
cp $PATH_VAGRANT/bash_aliases $PATH_HOME/.bash_aliases
cp $PATH_VAGRANT/bash_env_vars $PATH_HOME/.bash_env_vars

# setup custom ssh config
cp $PATH_VAGRANT/ssh/config $PATH_HOME/.ssh/config
chmod 0400 $PATH_HOME/.ssh/authorized_github_key

# Stop httpd
sudo service apache2 stop 2> /dev/null

# Apache
sudo cp $PATH_VAGRANT/apache2/apache2.conf $PATH_HTTP/apache2.conf 2> /dev/null
sudo cp $PATH_VAGRANT/apache2/apache2.conf $PATH_HTTP/apache2.conf 2> /dev/null
sudo cp $PATH_VAGRANT/apache2/sites-available/* $PATH_HTTP/sites-available/ 2> /dev/null
sudo cp $PATH_VAGRANT/apache2/conf-available/* $PATH_HTTP/conf-available/ 2> /dev/null
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.2-fpm
# sudo a2ensite default-ssl

# Remove Apache holding page
# sudo rm -rf /var/www/html
sudo bash <<EOF
    chown -R vagrant:www-data /var/www/*
    find /var/www/* -type d -exec chmod 775 {} \;
    find /var/www/* -type f -exec chmod 644 {} \;
EOF

# PHP
PATH_VAGRANT_PHP=$PATH_VAGRANT/php
sudo cp $PATH_VAGRANT_PHP/php.ini $PATH_PHP/apache2/ 2> /dev/null
sudo cp $PATH_VAGRANT_PHP/php.ini $PATH_PHP/cli/ 2> /dev/null

# configure various php modules:

# Xdebug config
PATH_PHP_MODS=$PATH_PHP/mods-available
XDEBUG_INI=$PATH_PHP_MODS/xdebug.ini

# move template
sudo cp $PATH_VAGRANT_PHP/mods-available/xdebug.ini $XDEBUG_INI

# adjust placeholders
replaceInFile %HOST_IP $HOST_IP $XDEBUG_INI
replaceInFile %XDEBUG_LOG_PATH $XDEBUG_LOG_PATH $XDEBUG_INI

# disable_functions -- pcntl required by laravel queue, so custom mod created here, easy to turn off
sudo cp $PATH_VAGRANT_PHP/mods-available/disable_functions.ini $PATH_PHP_MODS/disable_functions.ini
sudo phpenmod disable_functions

# ensure default vagrant user can write regular apache files
usermod -a -G www-data vagrant

# todo. maybe later
# /etc/mysql/mysql.cnf
# Copy ssh keys if mounted
# leave be for now until we determine a use case
# if [ -d "$PATH_SSH" ]; then
#   cp $PATH_SSH/id_rsa $PATH_HOME/.ssh/id_rsa
#   cp $PATH_SSH/id_rsa.pub $PATH_HOME/.ssh/id_rsa.pub
#   chmod 600 $PATH_HOME/.ssh/id_rsa*
#   chown vagrant:vagrant $PATH_HOME/.ssh/id_rsa*
# fi

###################################################################################
echo " # 3. Customizing machine..."
###################################################################################

loadBoxCustomizersFromDirectory "$PATH_VAGRANT/post-provisions/"
loadBoxCustomizersFromDirectory "$PATH_VAGRANT/post-provisions/bionic/"

###################################################################################
echo " # 4. Final cleanup..."
###################################################################################

# Restart Apache
sudo service apache2 start 2> /dev/null


###################################################################################
# eof
