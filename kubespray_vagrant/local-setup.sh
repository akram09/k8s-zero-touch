#!/bin/bash

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
  # Reading python version
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
  


cp ../local-config.rb .
# setting up config variable 
export KUBESPRAY_VAGRANT_CONFIG=./local-config.rb
vagrant up 
