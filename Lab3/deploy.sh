#!/bin/bash

set -e
set -u
set -o pipefail
set -x


# terraform init -upgrade && terraform apply

if [ $# -ne 2 ]; then
    echo "2 args required"
    exit 1
fi

RESOURCE_GROUP_NAME=$1
CLUSTER_NAME=$2

az aks get-credentials \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $CLUSTER_NAME

kubectl get nodes

cd spring-petclinic-cloud/
kubectl apply -f k8s/init-namespace/
kubectl apply -f k8s/init-services


kubectl get svc -n spring-petclinic
kubectl get sc

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --version 9.4.6 --set auth.database=service_instance_db
helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic  --version 9.4.6 --set auth.database=service_instance_db
helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic  --version 9.4.6 --set auth.database=service_instance_db

export REPOSITORY_PREFIX=springcommunity

./scripts/deployToKubernetes.sh
kubectl get svc -n spring-petclinic
