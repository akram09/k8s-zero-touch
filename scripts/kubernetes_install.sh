#!/bin/bash


#################################################
#      Kubernetes Installation (Kubectl kubeadm)#
#################################################


# disable swap 
sudo swapoff -a

# keeps the swap off during reboot
sudo sed -i 's/^\(.*swap.*$\)/#\1/g' /etc/fstab

# Installation of basic packages 
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
# Adding gpg key of kubernetes 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -


## Adding kubernetes repository list to apt 
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

## Update apt repositories 
sudo apt-get update -y
## installing kubectl and kubelet and kubeadm
sudo apt-get install -y kubelet=1.23.5-00 kubeadm=1.23.5-00 kubectl=1.23.5-00



## Holding packages version to save them from the system upgrade 
sudo apt-mark hold kubelet kubeadm kubectl



# Restarting the kubelet 
sudo systemctl daemon-reload
sudo systemctl restart kubelet