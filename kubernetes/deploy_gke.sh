#!/bin/bash
set -e

PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="devsecops-cluster"
ZONE="us-central1-a"
REPO_NAME="flask-app"
IMAGE="gcr.io/$PROJECT_ID/$REPO_NAME:latest"

# Autenticação
gcloud auth login
gcloud config set project $PROJECT_ID

# Ativar APIs necessárias
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

# Criar cluster
gcloud container clusters create $CLUSTER_NAME --zone $ZONE --num-nodes=2

# Autenticar kubectl
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

# Build + Push imagem
docker build -t $IMAGE .
gcloud auth configure-docker
docker push $IMAGE

# Atualizar imagem no YAML e aplicar
sed -i "s|image: .*|image: $IMAGE|" kubernetes/deployment.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml