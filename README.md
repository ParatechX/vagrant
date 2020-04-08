# Vagrant configuration for LAMP server on Ubuntu Bionic 64bit

## Pre-requisites

* OSX: recommend installing with `brew`! Dependencies are a pain otherwise...
* Vagrant [tested on 2.2.5]
    * **VagrantPlugins:**
    * landrush [tested on 1.3.2]: `vagrant plugin uninstall landrush`

* Virtualbox [tested on 6.0.4]

## Installation

Checkout branch for server/application type you require.

## Available Boxes:
* [box/dot](/box-docs/DOT_README.md)
* check repo for other branches... 

## To spin up web server for the first time, run:

1. Run > vagrant box add ubuntu/bionic64
1. Checkout the branch for the server you want to spin up
1. Run > vagrant up lamp

## To create a new server/application, follow these steps...

1. Create a new branch: git checkout -b box/application_name`
1. Edit/Update /bootstrap.sh to provision packages and software.
1. Edit the /settings.yml to specify/configure the container itself.
1. Run vagrant up [ lamp ]

## Other useful tools:
* SequelPro -- connect to database via ssh tunnel
* Vagrant plugin: hostsupdater -- https://github.com/cogitatio/vagrant-hostsupdater
