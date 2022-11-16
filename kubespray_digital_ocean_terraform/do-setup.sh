#!/bin/bash


# sourcing the environment variables 
export $(cat .env | xargs)

#initialize terraform 
terraform init 
# plan the terraform execution
terraform plan 

# apply the executioon plan
terraform apply



# Nodes created, we get their ip addresses
MASTER_NODE_IP=$(terraform output -raw ip_master)
NODE_1_IP=$(terraform output -raw ip_node-1)
NODE_2_IP=$(terraform output -raw ip_node-2)


############################################
#        Ansible install and kubesoray     #
############################################
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray

if ! [ -d "./$KUBESPRAYDIR" ]; then
  # clone kubespray
  git clone git@github.com:kubernetes-sigs/kubespray.git
fi


# check if the virtual environment folder exists already
# if that is the case all requirements are installed we
# just activate the virtual environment
if  [ -d "./$VENVDIR" ]; then
  echo "Virtual environment folder already exists, skipping creating "
else
  PYTHON_VERSION=$(python --version | awk '{ print $2 }')

  # spliting the version and converting to double
  IFS="."
  read -a version_array <<<"$PYTHON_VERSION"
  PYTHON_MAJOR_VERSION=$version_array[0]
  PYTHON_MINOR_VERSION=$version_array[1]
  # check python version and assign the correct ansible version
  if [[ $PYTHON_MAJOR_VERSION == "3" ]]; then
          if [ 8 -ge $((PYTHON_MINOR_VERSION)) ] && [ $((PYTHON_MINOR_VERSION)) -le 10 ]; then
                  ANSIBLE_VERSION=2.12
          else
                  ANSIBLE_VERSION=2.11
          fi
  else
          ANSIBLE_VERSION=2.11
  fi
  IFS=""
  virtualenv --python=$(which python3) $VENVDIR
fi

# Activating virtual environment
source $VENVDIR/bin/activate

cd $KUBESPRAYDIR || exit

# Installing ansible requirements
pip install -U -r requirements-$ANSIBLE_VERSION.txt
test -f requirements-$ANSIBLE_VERSION.yml &&
        ansible-galaxy role install -r requirements-$ANSIBLE_VERSION.yml &&
        ansible-galaxy collection -r requirements-$ANSIBLE_VERSION.yml



# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=($MASTER_NODE_IP $NODE_1_IP $NODE_2_IP)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

cp ../config/k8s-cluster.yaml inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
ansible-playbook -i inventory/mycluster/hosts.yaml -u root --private-key=~/.ssh/digital_ocean_ssh  --become --become-user=root cluster.yml


