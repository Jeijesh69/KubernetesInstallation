#!/bin/bash

# Apply the Tigera operator for Calico
echo "Applying Tigera operator..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Download the custom resources file for Calico
echo "Downloading custom resources YAML..."
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml

# Apply the custom resources to configure Calico
echo "Applying custom resources..."
kubectl apply -f custom-resources.yaml

# Wait a moment for Calico pods to be deployed and running
echo "Waiting for Calico pods to be in running state..."
sleep 60

# Check if the Calico pods are running
kubectl get pods -n calico-system

# Check the node status to ensure the master node is in Ready state
echo "Checking the node status..."
kubectl get nodes
