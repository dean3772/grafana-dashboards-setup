#!/bin/bash

# Exit on any error
set -e

# Navigate to the Terraform infrastructure directory and apply configuration
pushd terraform/infra
terraform init
terraform apply -auto-approve

# Update kubeconfig with the EKS cluster details
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
popd

# Apply Kubernetes configurations
kubectl apply -f k8s/monitoring-namespace.yaml
kubectl apply -f k8s/apps-namespace.yaml
kubectl apply -f k8s/nginxdeployment.yaml
kubectl apply -f k8s/nginxservice.yaml

# Install Prometheus and Grafana with Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install promgrafana prometheus-community/kube-prometheus-stack --namespace monitoring -f k8s/grafana/values.yaml ||

# Extract Grafana URL
GRAFANA_URL=$(kubectl get svc promgrafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --namespace monitoring)
echo "Grafana URL: $GRAFANA_URL"

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
sleep 60  # Wait for 60 seconds. Adjust this based on your environment.

# Generate Grafana API Token
GRAFANA_API_TOKEN=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"terraform", "role":"Admin"}' http://admin:prom-operator@$GRAFANA_URL/api/auth/keys | jq -r '.key')
echo "Generated Grafana API Token"

# Export Grafana API Token for Terraform
export TF_VAR_grafana_auth_token=$GRAFANA_API_TOKEN
echo "Exported Grafana API Token as TF_VAR_grafana_auth_token"

# Export Grafana URL for Terraform
export TF_VAR_grafana_url="http://$GRAFANA_URL"
echo "Exported Grafana URL as TF_VAR_grafana_url"

# Apply Grafana dashboards with Terraform
pushd terraform/grafana
terraform init
terraform apply -auto-approve
popd

# Output Grafana ELB Address
echo "Grafana ELB Address:"
kubectl get svc promgrafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --namespace monitoring

