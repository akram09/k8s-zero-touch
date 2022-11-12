#!/bin/bash 
###  Setup of Cluster Nodes  ############
#########################################

set -euxo pipefail

# disable swap
sudo swapoff -a


# keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true


# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system


##############################################
#####      CRI-O Installation           ######
##############################################

# Specify the version of ubuntu
UBUNTU_VERSION="xUbuntu_20.04"
# Specify the version of crio 
CRI_O_VERSION="1.24"


echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$UBUNTU_VERSION/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${CRI_O_VERSION}/$UBUNTU_VERSION/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:${CRI_O_VERSION}.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${CRI_O_VERSION}/$UBUNTU_VERSION/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$UBUNTU_VERSION/Release.key | apt-key add -

# Install cri 
apt-get update -y 
apt-get install cri-o cri-o-runc -y 

# Enable cri-o 
sudo systemctl daemon-reload
sudo systemctl enable crio --now


##############################################
#####      Kubernetes  Installation     ######
##############################################

# Set Kubernetes version 
KUBERNETES_VERSION=1.24


sudo apt-get install -y apt-transport-https ca-certificates curl

# Get apt key 
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Adding kubernetes to local repository 
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update -y 

# Install kubernetes and kubeadm
sudo apt-get install -y kubelet=$KUBERNETES_VERSION  kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION


# Mark the current version 
sudo apt-mark hold kubelet kubeadm kubectl