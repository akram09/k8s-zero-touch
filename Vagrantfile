# -*- mode: ruby -*-
# vi: set ft=ruby :


## read environment variables 
CLUSTER_SUBNET_IP="10.0.0."
WORKERS_PREFIX_NAME="worker-"
WORKERS_NUMBER=2
MASTER_NODE_NAME="master-node"


Vagrant.configure("2") do |config|

  # setup default box 
  config.vm.box = "bento/ubuntu-21.10"

  # activate the check update feature 
  config.vm.box_check_update = true



  # create the master vm 
  config.vm.define MASTER_NODE_NAME do |master|
    master.vm.hostname = MASTER_NODE_NAME
    master.vm.network "private_network", ip: CLUSTER_SUBNET_IP+"2" 
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 4048
      vb.cpus = 3
    end
    # Add scripts to setup the master node 
#    master.vm.provision "shell", path: "scripts/common.sh"
    # ....
  end 

  # create the workers nodes 
  (1..WORKERS_NUMBER).each do |i|
    # for each worker node 
    config.vm.define WORKERS_PREFIX_NAME + "#{i}" do |worker|
      # set the hostname 
      worker.vm.hostname = WORKERS_PREFIX_NAME + "#{i}"
      # set the ip address 
      worker.vm.network "private_network", ip: CLUSTER_SUBNET_IP+"#{i+3}" 
      # set the memory and cpu 
      worker.vm.provider "virtualbox" do |vb|
        vb.memory = 4048
        vb.cpus = 3
      end
      # Launch scripts in Virtual Machine 
#      worker.vm.provision "shell", path: "scripts/common.sh"
    end 
  end
end
