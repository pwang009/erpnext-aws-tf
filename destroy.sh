#!/bin/bash

set -e

echo "🗑️ Destroying ERPNext deployment..."

# Destroy Terraform resources
echo "🧹 Destroying Terraform resources..."
terraform destroy -auto-approve

echo "✅ Destruction complete! All resources have been removed."