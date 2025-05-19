#!/bin/bash
set -e

CLUSTER_NAME="devsecops-cluster"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_NAME="flask-app"

# Criar ECR
aws ecr create-repository --repository-name $REPO_NAME || true

# Build + Push da imagem
docker build -t $REPO_NAME .
docker tag $REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest

# Criar cluster EKS
eksctl create cluster --name $CLUSTER_NAME --region $REGION --nodes 2

# Configurar kubectl
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

# Atualizar imagem no YAML e aplicar
sed -i "s|image: .*|image: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest|" kubernetes/deployment.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml