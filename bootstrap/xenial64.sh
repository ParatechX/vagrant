#!/usr/bin/env bash

###################################################################################
###                                                                   		 	###
### 	 Shell script to install packages, configure, import configuration	 	###
### 	 and manage services for a single box standard web lamp stack     	 	###
### 	 running Ubuntu Trusty 													###
###                                                                   		 	###
###################################################################################

# Params
###################################################################################

PATH_LIB="/var/www/lib"
PATH_HOME="/home/vagrant"
PATH_HTTP="/etc/apache2"
PATH_VAGRANT="/var/vagrant"
PATH_WEB="/var/www/html"
PATH_FREETDS="/etc/freetds"
PATH_PHP="/etc/php5"

###################################################################################
echo " # 1. Installing Packages..."
###################################################################################

# Node.js (looks like this forces an apt-get update so do it first)
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g grunt-cli

# PHP
# NOTE: Not sure if specifying versions here is the right way to go. The repo
# may only store the latest so these could drop out. We'll see.
sudo apt-get install -y php5=5.5*
sudo apt-get install -y php5-mcrypt=5.4*
sudo apt-get install -y php5-gd=5.5*
sudo apt-get install -y php5-mysql=5.5*
sudo apt-get install -y php5-intl=5.5*
sudo apt-get install -y php5-xsl=5.5*
sudo apt-get install -y php5-curl=5.5*
sudo apt-get install -y php5-xdebug=2.2*
sudo apt-get install -y php-pear=5.5*
sudo apt-get install -y php-soap=0.13*
sudo apt-get install -y php5-tidy
# sudo apt-get install -y pdo-mysql
# sudo apt-get install -y php-mysql=5.5*

# Misc PHP Packages
sudo apt-get install -y ImageMagick

# FreeTDS
sudo apt-get install -y freetds-common freetds-bin unixodbc php5-sybase

# Git
sudo apt-get install -y git

# Composer
cd /tmp && curl -sS https://getcomposer.org/installer | php
sudo mv /tmp/composer.phar /usr/local/bin/composer

# MySQL
sudo apt-get install -y mysql-client-5.6

###################################################################################
echo " # 2. Copying Files..."
###################################################################################

# Convenience link
ln -s /var/www/html /home/vagrant/html

# Aliases
cat $PATH_VAGRANT/alias_list >> $PATH_HOME/.bashrc

# Stop httpd
sudo service apache2 stop 2> /dev/null

# Apache
sudo cp $PATH_VAGRANT/apache2/apache2.conf $PATH_HTTP/apache2.conf 2> /dev/null
sudo cp $PATH_VAGRANT/apache2/sites-available/* $PATH_HTTP/sites-available/ 2> /dev/null
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2ensite default-ssl

# Remove Apache holding page
# sudo mv $PATH_WEB/index.html $PATH_WEB/index.html.0
sudo rm -rf $PATH_WEB/index.html 

# Mcrypt fix
sudo ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
sudo ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
# ln -s ../../mods-available/mcrypt.ini 20-mcrypt.ini

# PHP
sudo cp $PATH_VAGRANT/php.ini $PATH_PHP/apache2/ 2> /dev/null
sudo cp $PATH_VAGRANT/php.ini $PATH_PHP/cli/ 2> /dev/null

# Xdebug config (for PHPSTORM)
sudo cp $PATH_VAGRANT/xdebug.ini $PATH_PHP/mods-available/xdebug.ini
echo "export XDEBUG_CONFIG=\"idekey=PHPSTORM\"" >> $PATH_HOME/.bashrc

# FreeTDS
sudo cp $PATH_VAGRANT/freetds.conf $PATH_FREETDS/ 2> /dev/null

# Restart Apache
sudo service apache2 start 2> /dev/null

# Copy ssh keys if mounted
if [ -d "$PATH_HOME/ssh" ]; then
  cp $PATH_HOME/ssh/id_rsa $PATH_HOME/.ssh/id_rsa
  cp $PATH_HOME/ssh/id_rsa.pub $PATH_HOME/.ssh/id_rsa.pub
  chmod 600 $PATH_HOME/.ssh/id_rsa*
  chown vagrant:vagrant $PATH_HOME/.ssh/id_rsa*
fi

###################################################################################
# eof