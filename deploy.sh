#!/bin/bash

# NestJS Kubernetes Deployment Script
set -e

echo "🚀 Starting NestJS Kubernetes deployment..."

# Step 1: Build Docker Image
echo "📦 Building Docker image..."
docker build -t nestjs-app:latest .

echo "📤 Pushing image to Docker Hub..."
# Tag with your Docker Hub username
docker tag nestjs-app:latest changlee0216/nestjs-app:latest
# Push to Docker Hub (requires: docker login)
docker push changlee0216/nestjs-app:latest

# Step 2: Clean existing resources
echo "🧹 Cleaning existing Kubernetes resources..."
kubectl delete deployment nestjs-deployment -n nestjs-app --ignore-not-found=true
kubectl delete service nestjs-service -n nestjs-app --ignore-not-found=true
kubectl delete ingress nestjs-ingress -n nestjs-app --ignore-not-found=true

# Step 3: Deploy Infrastructure
echo "🏗️  Cleaning and initializing Terraform..."
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan
terraform init

echo "🚀 Applying Terraform configuration..."
terraform import kubernetes_namespace.nestjs nestjs-app
terraform apply -auto-approve

# Step 4: Verify Deployment
echo "✅ Checking deployment status..."
kubectl get pods -n nestjs-app

echo "🌐 Getting service details..."
kubectl get svc -n nestjs-app

echo "🎉 Deployment completed!"
echo "📝 Add '127.0.0.1 nestjs.local' to /etc/hosts for local access"
echo "🌍 Application accessible at: http://nestjs.local"
echo "🚀 Starting port-forward to localhost:3000..."
echo "Press Ctrl+C to stop port-forwarding"
kubectl port-forward svc/nestjs-service 3000:80 -n nestjs-app