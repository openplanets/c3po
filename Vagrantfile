# -*- mode: ruby -*-
# vi: set ft=ruby :

AVAILABLE_MEMORY = 2048
# variable definitions also to be passed on provisioner
# PLAY_HOST_PORT = PLAY_GUEST_PORT = 9000
MONGOD_HOST_PORT = MONGOD_GUEST_PORT = 27017
MONGOADMIN_HOST_PORT = MONGOADMIN_GUEST_PORT = 28017
# WELCOME_HOST_PORT = WELCOME_GUEST_PORT = 8000


# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "hashicorp/precise64"

  # config.vm.network "forwarded_port", guest: PLAY_GUEST_PORT, host: PLAY_HOST_PORT # playframework
  config.vm.network "forwarded_port", guest: MONGOD_GUEST_PORT, host: MONGOD_HOST_PORT # mongodb port
  config.vm.network "forwarded_port", guest: MONGOADMIN_GUEST_PORT, host: MONGOADMIN_HOST_PORT # mongodb admin
  # config.vm.network "forwarded_port", guest: WELCOME_GUEST_PORT, host: WELCOME_HOST_PORT # shares vm-internal files

  # Run the provisioning script
  SHELL_ARGS = [
    # PLAY_GUEST_PORT,
    MONGOD_GUEST_PORT,
    MONGOADMIN_GUEST_PORT,
    # WELCOME_GUEST_PORT,
  ]
  config.vm.provision :shell, :path => ".provision/setup.sh", :args => "%s %s" %SHELL_ARGS

  config.vm.provider "virtualbox" do |vb|
     vb.customize ["modifyvm", :id, "--memory", AVAILABLE_MEMORY]
   end
end
