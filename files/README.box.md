# Vagrant configuration for LAMP server on Ubuntu Bionic 64bit

## requirements:
* `brew cask install virtualbox`
* `brew install vagrant`
* `vagrant plugin install landrush`
* `vagrant plugin install hostsupdater`


## SETUP

### External DB setup
1. make a folder box, ie: `~/box/mysql57`
1. clone vagrant repo into folder `git clone git@github.com:ParatechX/vagrant.git .`
1. switch to dot branch `git checkout box/dot`
1. add local config file from defaults `cp default.config.yml local.config.yml`
   * adjust at least: `hostname`, `ip`, `live_apps_folder`, `auth_key`, `bootstrap`, remove other keys as the default file will load them anyways
   * recommended hostname: `database.local`
   * update IP address: `ip: '192.168.100.102'`
   * set bootstrap to db-only: `bootstrap: 'bionic64-db-only.sh'`
   * reference your shared key details for cross machine connections
1. `vagrant up` to finish setup
1. bionic64-db-only.sh script automatically sets up database default user:password (`vagrant`:`vagrant`) with access to `dot_dev_backend` which is also created by default

### API machine setup (without DB)
1. make a folder box, ie: `~/box/dot`
1. clone vagrant repo into folder `git clone git@github.com:ParatechX/vagrant.git .`
1. switch to dot branch `git checkout box/dot`
1. add local config file from defaults `cp default.config.yml local.config.yml`
    * adjust at least: `hostname`, `live_apps_folder`, `auth_key`, remove other keys as the default file will load them anyways
    * recommended hostname: `dot.dev.paratech.local`
    * make sure reference folders on hostmachine exist, ie: `mkdir ~/code/dot/backend`
    * reference your shared key details for cross machine connections
1. `vagrant up` to finish setup
* **After each reboot**
  1. `vagrant ssh` to enter box
  1. run `tunneldb` to setup port forwarding to db-box via port 3307, and access db from code-box via `dbt`


### API machine setup (with DB)
* **TODO** test if it works without tweaking...


### Result:
* code-box running on `dev.dot.paratech.local` with all subdomains sent to root folder (default: `/var/www/backend/`) 
* db-box running on `database.local` with un/pw: `vagrant`/`vagrant`


## Performance Tweaks:
### Running composer install/update? try adding swap file for more punch.
* bionic script configures swapfile upon provision. 
* Enable: `sudo swapon /swapfile`
* Disable:  `sudo swapoff /swapfile`

## ...Works in progress:
### Database Tunneling:
* using it to preserve db details while being able to destroy code-vm as needed
* tunnel setup, run after each reboot on code-box, until it becomes part of box script: 
  * `ssh -f vagrant@[DB-BOX-IP] -i /home/vagrant/ssh/[YOUR-SHARED-PUBLIC-KEY] -L 3307:localhost:3306 -N`
  * or alias: 'tunneldb'


 


