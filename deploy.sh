#!/bin/bash

set -e

echo "🚀 Deploying ERPNext on AWS..."

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=erpnext.plan

# Apply configuration
echo "🛠️ Applying configuration..."
terraform apply erpnext.plan

# Configure kubectl
echo "🔧 Configuring kubectl..."
aws eks update-kubeconfig --region us-west-1 --name expn01-cluster

# Wait for pods to be ready
echo "⏳ Waiting for ERPNext pods to be ready..."
kubectl wait --for=condition=ready pod -l app=erpnext -n expn01 --timeout=600s

# Get Load Balancer URL
echo "🌐 Getting Load Balancer URL..."
LB_URL=$(kubectl get svc -n expn01 expn01-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "✅ Deployment complete!"
echo "📊 Access your ERPNext instance at: http://$LB_URL"
echo "💾 Database endpoint: $(terraform output -raw rds_endpoint)"
echo "🪣 S3 Bucket: $(terraform output -raw s3_bucket_name)"