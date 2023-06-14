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

az aks get-credentials \
    --resource-group $1 \
    --name $2


cd spring-petclinic-cloud/
kubectl apply -f k8s/init-namespace/
kubectl create secret generic wavefront -n spring-petclinic --from-literal=wavefront-url=https://wavefront.surf --from-literal=wavefront-api-token=2e41f7cf-1111-2222-3333-7397a56113ca
kubectl apply -f k8s/init-services


kubectl get svc -n spring-petclinic
kubectl get sc

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --version 9.4.6 --set auth.database=service_instance_db
helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic  --version 9.4.6 --set auth.database=service_instance_db
helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic  --version 9.4.6 --set auth.database=service_instance_db

./scripts/deployToKubernetes.sh
kubectl get svc -n spring-petclinic
