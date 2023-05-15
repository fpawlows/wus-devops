#!/bin/sh
sudo apt update -y
sudo apt upgrade -y
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo apt install python3-pip

python3 -m pip install ansible
ansible-galaxy collection install azure.azcollection

sudo pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt

az login