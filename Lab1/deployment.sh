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
NETWORK_NAME=="$(jq -r '.network.name' "$CONFIG_FILE")"


echo $RESOURCE_GROUP_NAME
echo $LOCATION

az group create --name \
    --$RESOURCE_GROUP_NAME \
    --location $LOCATION

 
az network vnet create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $NETWORK_NAME \
    --address-prefix $NETWORK_ADDR_PREFIX

#readarray -t NETWORK_SECURITY_GROUPS < <(jq -c ')
readarray -t DEPLOYMENTS < <(jq -c '.deployments[]' "$CONFIG_FILE")

for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do   
    echo $DEPLOYMENT

    DEPLOYMENT_NAME=$(jq -r '.name' "$CONFIG_FILE")
    # Network Security Groups
    NSG_NAME="${DEPLOYMENT_NAME}NSG"
    az network nsg create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $NSG_NAME 

    # Rules
    #PORT=$(jq -c '.subnet.port' <<< "$CONFIG_FILE")
    #SUBNET=$(jq -c '.subnet' <<< "$CONFIG_FILE")

    #RULES=$(jq -c '.subnet.rules[]' <<< "$CONFIG_FILE")
    #for RULE in "${RULES}"; do
    #    echo $RULE

    PORT=$(jq -c '.subnet.port' <<< "$CONFIG_FILE")    

    az network nsg rule create \
        --resource-group $RESOURCE_GROUP_NAME \
        --nsg-name $DEPLOYMENT \
        --name "${DEPLOYMENT}Rule" \
        --access allow \
        --protocol Tcp \
        --priority 900 \
        --destination-port-ranges $PORT
        #TODO skipped unused values - may cause errors

    # Subnet Creation
    SUBNET_NAME="${DEPLOYMENT_NAME}SubNet"
    az network vnet subnet create \
        --resource-group $RESOURCE_GROUP_NAME \
        --vnet-name $NETWORK_NAME \
        --name $SUBNET_NAME 

    # Public ips
    PUBLIC_IP=$(jq -c '.subnet.public_ip' <<< "$CONFIG_FILE")

    az network public-ip create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $PUBLIC_IP
#done

#VM Create
VM_PRIVATE_IP_ADDRESS=$(jq -r 'virtual_machine.private_ip_address' <<< $DEPLOYMENT)
VM_PUBLIC_IP_ADDRESS=$(jq -r 'virtual_machine..public_ip_address' <<< $DEPLOYMENT)
VM_NAME="${DEPLOYMENT_NAME}VM"
az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --vnet-name $NETWORK_NAME \
    --name $VM_NAME \
    --subnet $SUBNET_NAME \
    --nsg "" \
    --private-ip-address $VM_PRIVATE_IP_ADDRESS \
    --public-ip-address $VM_PUBLIC_IP_ADDRESS \
    --image UbuntuLTS \
    --generate-ssh-keys
    #TODO sizes

readarray -t DEPLOY < <(jq -c '.deploy[]' <<< $DEPLOYMENT)

for SERVICE in "${DEPLOY[@]}"; do
    echo $SERVICE

    case $DEPLOYMENT_NAME in
        frontend)
            echo Frontend setup

            az vm run-command invoke \
                --resource-group $RESOURCE_GROUP_NAME \ 
                --name $VM_NAME \
                --commnad-id RunShellScript \
                --scripts "@./front.sh" \
;;

done

