#!/bin/bash

################################################
#      Script for installing docker            #
################################################



# update apt respositories 
sudo apt-get update -y 

# install essential packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
		software-properties-common 

# Adding gpg docker key 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adding docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installing docker 
sudo apt-get update -y 
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 

echo "Docker Runtime Installed Successfully"

echo "Running Docker Post Installation scripts"

# Post Install docker 

# creation of docker group 
sudo groupadd docker

# Adding user to the docker group 
# Optional if you are using the root user then there is no need 
sudo usermod -aG docker $USER

# configure docker runtime 

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Launching docker service 
sudo systemctl enable docker.service

sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker Post Installation done successfully"