#!/bin/bash

# Set up the environment
sudo apt-get update
sudo apt-get upgrade -y

sudo apt install jq -y
sudo apt-get install azure-cli -y

# Login to Azure
az login

# Create resource group
CONFIG_FILE="$1"
RESOURCE_GROUP_NAME="$(jq -r '.resource_group_name' "$CONFIG_FILE")"
LOCATION="$(jq -r '.location' "$CONFIG_FILE")"
NETWORK_ADDR_PREFIX="$(jq -r 'network.address_prefix' "$CONFIG_FILE")"

echo $RESOURCE_GROUP_NAME
echo $LOCATION

az group create --name \
    --$RESOURCE_GROUP_NAME \
    --location $LOCATION

 
az network vnet create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name Frontend_subnet \
    --address-prefix $NETWORK_ADDR_PREFIX

readarray -t SUBNETS < <(jq -c '.subnets[]' "$CONFIG_FILE")

for SUBNET in "${SUBNETS[@]}"; do   
    echo $SUBNET
    

done