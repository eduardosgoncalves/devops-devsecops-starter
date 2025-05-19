#!/bin/bash
set -e

RESOURCE_GROUP="DevSecOps-RG"
AKS_CLUSTER="devsecops-aks"
ACR_NAME="devsecopsregistry"
IMAGE="flask-app"
ACR_IMAGE="$ACR_NAME.azurecr.io/$IMAGE:latest"

# Login e criação de grupo
az login
az group create --name $RESOURCE_GROUP --location eastus

# Criar ACR
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

# Build + Push
az acr login --name $ACR_NAME
docker build -t $ACR_IMAGE .
docker push $ACR_IMAGE

# Criar AKS com integração ao ACR
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_CLUSTER \
  --node-count 2 \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME

# Configurar kubectl
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER

# Atualizar imagem no YAML e aplicar
sed -i "s|image: .*|image: $ACR_IMAGE|" kubernetes/deployment.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml