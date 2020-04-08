# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

# Read YAML config files
current_dir = File.dirname(File.expand_path(__FILE__))
local_config_file         = "#{current_dir}/local.config.yml"
default_config_file       = "#{current_dir}/default.config.yml"

# load the default values
default_settings = YAML.load_file(default_config_file).first()

# a simple minded way to allow overrides that are not affected by branch updates
if File.file?(local_config_file)
    local_settings = YAML.load_file(local_config_file).first()
else 
    local_settings = {}
end

# local settings will overwrite branch defaults
settings = default_settings.merge(local_settings)

# verify settings if needed:
# puts settings.inspect

# Vagrant Settings
VAGRANTFILE_API_VERSION = "2"

# do some basic checks to make sure we have all required plugins
unless Vagrant.has_plugin?("landrush")
  puts '[landrush] plugin required. To install simply do `vagrant plugin install landrush`'
  abort
end

unless Vagrant.has_plugin?("vagrant-hostmanager")
  puts '[vagrant-hostmanager] plugin required. To install simply do `vagrant plugin install vagrant-hostmanager`'
  abort
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

config.vm.provider "virtualbox" do |v|
    # this allows us to symlink local code folders into live_code and share it with vm
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/SHARE_NAME", "1"]
end

###################################################################################

  config.vm.provider "virtualbox" do |v|
    v.memory = settings['memory']
  end

  #dns resolver
  config.landrush.enabled = true

  # ssh settings
  config.ssh.insert_key = false
  config.ssh.private_key_path = [settings['auth_key']['private'], "~/.vagrant.d/insecure_private_key"]
  config.vm.provision "file", source: settings['auth_key']['public'], destination: "~/.ssh/authorized_keys"
  
  # if you want to git from inside guest, make sure to set this
  config.vm.provision "file", source: settings['auth_key']['github'], destination: "~/.ssh/authorized_github_key"
  
  # disable password authentication
  config.vm.provision "shell", inline: <<-EOC
    sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
    sudo service ssh restart
  EOC

  # make sure the domains resolve locally
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  # config.hostmanager.ignore_private_ip = false
  # config.hostmanager.include_offline = true

  # Web
  config.vm.define "lamp" do |lamp|
    lamp.vm.box =                                     "ubuntu/bionic64"
    lamp.vm.hostname =                                settings['hostname']
    lamp.vm.network :private_network, ip:             settings['ip']

    if settings['aliases']
      # adds them to /etc/hosts domain entry
      lamp.hostmanager.aliases = settings['aliases']
    end
    
    if settings['subdomains_on_hostname']
      # helps resolve any dynamic subdomains to this hostname
      lamp.landrush.tld = settings['hostname']
    end
    
    # folders that contain live code edited on host machine
    settings['apps'].each do |key, app|
      lamp.vm.synced_folder app['sync']['local'], 
        app['sync']['virtual'],
        owner: "vagrant",
        group: "www-data",
        mount_options: ["dmode=775,fmode=664"]
    end

    # folder that will be used to share provisioning scripts
    lamp.vm.synced_folder       settings['box_folder']['local'],      settings['box_folder']['virtual']

    # access to various keys here
    lamp.vm.synced_folder       settings['ssh_folder']['local'],      settings['ssh_folder']['virtual']

    lamp.vm.provision :shell do |s| 
      s.path = "bootstrap/#{settings['bootstrap']}"
      s.args = [
        settings['box_folder']['virtual'],
        settings['ssh_folder']['virtual'],
        settings['ip'],
      ]
    end
  end

  # cleanup headache producers
  config.trigger.after :destroy do |trigger|
    trigger.info = "Removing known_hosts entries"
    trigger.run = {inline: "ssh-keygen -R #{settings['hostname']}"}
    trigger.run = {inline: "ssh-keygen -R #{settings['ip']}"}
  end 
###################################################################################
end
