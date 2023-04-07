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
# TODO these need to be different for every network... or do they?
NETWORK_ADDR_PREFIX="$(jq -r '.network.address_prefix' "$CONFIG_FILE")"
NETWORK_NAME="$(jq -r '.network.name' "$CONFIG_FILE")"


az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION

 
az network vnet create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $NETWORK_NAME \
    --address-prefix $NETWORK_ADDR_PREFIX

readarray -t DEPLOYMENTS < <(jq -c '.deployments[]' "$CONFIG_FILE")

for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do   
    DEPLOYMENT_NAME=$(jq -r '.name' <<< "$DEPLOYMENT")
    echo $DEPLOYMENT_NAME Network Security Groups creation
    NSG_NAME="${DEPLOYMENT_NAME}NSG"
    az network nsg create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $NSG_NAME 

    # Rules
    #PORT=$(jq -c '.subnet.port' <<< "$DEPLOYMENT")
    #SUBNET=$(jq -c '.subnet' <<< "$DEPLOYMENT")

    #RULES=$(jq -c '.subnet.rules[]' <<< "$DEPLOYMENT")
    #for RULE in "${RULES}"; do
    #    echo $RULE

    PORT=$(jq -c '.subnet.port' <<< "$DEPLOYMENT")
    SUBNET_ADDR_PREFIXES=$(jq -r '.subnet.address_prefixes' <<< "$DEPLOYMENT")

    az network nsg rule create \
        --resource-group $RESOURCE_GROUP_NAME \
        --nsg-name $NSG_NAME \
        --name "${DEPLOYMENT_NAME}Rule" \
        --access allow \
        --protocol Tcp \
        --priority 900 \
        --destination-port-ranges $PORT
        #TODO skipped unused values - may cause errors

    echo $DEPLOYMENT_NAME subnet creation
    SUBNET_NAME="${DEPLOYMENT_NAME}SubNet"
    az network vnet subnet create \
        --resource-group $RESOURCE_GROUP_NAME \
        --vnet-name $NETWORK_NAME \
        --network-security-group $NSG_NAME \
        --name $SUBNET_NAME \
        --address-prefixes $SUBNET_ADDR_PREFIXES

    echo $DEPLOYMENT_NAME public ips creation
    # TODO acquire real address
    PUBLIC_IP=$(jq -r '.virtual_machine.public_ip' <<< "$DEPLOYMENT")

    if [[ ! -z "$PUBLIC_IP" ]]; then
        az network public-ip create \
            --resource-group $RESOURCE_GROUP_NAME \
            --name $PUBLIC_IP
    fi

    echo $DEPLOYMENT_NAME VM creation
    VM_PRIVATE_IP_ADDRESS=$(jq -r '.virtual_machine.private_ip_address' <<< "$DEPLOYMENT")
    VM_NAME="${DEPLOYMENT_NAME}VM"
    # TODO check side effects of :- notation
    az vm create \
        --resource-group $RESOURCE_GROUP_NAME \
        --vnet-name $NETWORK_NAME \
        --name $VM_NAME \
        --subnet $SUBNET_NAME \
        --nsg $NSG_NAME \
        --private-ip-address $VM_PRIVATE_IP_ADDRESS \
        --public-ip-address "${PUBLIC_IP:-}" \
        --image UbuntuLTS \
        --generate-ssh-keys
    
        #TODO sizes and loop "vm create" over deployments for be/fe/db

    #TODO uncomment once we know VMs are properly configured
    # readarray -t DEPLOY < <(jq -c '.deploy[]' <<< $DEPLOYMENT)
    # for SERVICE in "${DEPLOY[@]}"; do
    #     case $DEPLOYMENT_NAME in
    #         frontend)
    #             echo Performing frontend setup...

    #             az vm run-command invoke \
    #                 --resource-group $RESOURCE_GROUP_NAME \ 
    #                 --name $VM_NAME \
    #                 --scripts "@./deployment_fe.sh"
    #                 # --command-id RunShellScript \
    #     ;;
    #         backend)
    #             echo Performing backend setup...
    #             az vm run-command invoke \
    #                 --resource-group $RESOURCE_GROUP_NAME \ 
    #                 --name $VM_NAME \
    #                 --scripts "@./deployment_be.sh"
    #     ;;
    #         *)
    #             echo Unknown setup $DEPLOYMENT_NAME
    #     ;;
    #     esac
    # done
done
