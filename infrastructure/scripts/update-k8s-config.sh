#!/bin/bash

# ===========================================
# UPDATE K8S CONFIGMAP WITH TERRAFORM OUTPUTS
# ===========================================

set -e

echo "🔧 Updating Kubernetes ConfigMap with Terraform outputs..."

# Get Redis connection details from Terraform
REDIS_HOST=$(terraform -chdir=infrastructure/environments/staging output -raw redis_host)
REDIS_PORT=$(terraform -chdir=infrastructure/environments/staging output -raw redis_port)
REDIS_PASSWORD=$(terraform -chdir=infrastructure/environments/staging output -raw redis_password)

echo "📋 Redis Configuration:"
echo "  Host: $REDIS_HOST"
echo "  Port: $REDIS_PORT"
echo "  Password: [HIDDEN]"

# Update ConfigMap
kubectl patch configmap microservices-config -n microservices-staging --type merge -p '{
  "data": {
    "REDIS_HOST": "'$REDIS_HOST'",
    "REDIS_PORT": "'$REDIS_PORT'",
    "REDIS_PASSWORD": "'$REDIS_PASSWORD'"
  }
}'

echo "✅ ConfigMap updated successfully!"

# Restart deployments to pick up new config
echo "🔄 Restarting deployments to apply new configuration..."
kubectl rollout restart deployment/todos-api -n microservices-staging
kubectl rollout restart deployment/users-api -n microservices-staging
kubectl rollout restart deployment/auth-api -n microservices-staging

echo "✅ Deployments restarted!"
echo "🎉 Configuration update complete!"
