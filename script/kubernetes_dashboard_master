#!/bin/bash

# Exit on error
set -e

# Step 1: Installing Helm
echo "[+] Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh

# Step 2: Adding Kubernetes Dashboard Helm repo
echo "[+] Adding Kubernetes Dashboard Helm repo..."
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# Step 3: Installing Kubernetes Dashboard
echo "[+] Installing Kubernetes Dashboard..."
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace \
  --namespace kubernetes-dashboard

# Step 4: Waiting for Dashboard pods to be ready
echo "[+] Waiting for Dashboard pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kubernetes-dashboard \
  -n kubernetes-dashboard --timeout=120s

# Step 5: Exposing the Dashboard on NodePort
echo "[+] Exposing Dashboard on NodePort..."
kubectl expose deployment kubernetes-dashboard-kong \
  --name k8s-dash-svc \
  --type NodePort \
  --port 443 \
  --target-port 8443 \
  -n kubernetes-dashboard

# Step 6: Creating ServiceAccount and ClusterRoleBinding
echo "[+] Creating ServiceAccount + ClusterRoleBinding..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jeshica
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jeshica-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jeshica
  namespace: kube-system
EOF

# Step 7: Generating login token (valid for 1 year)
echo "[+] Generating login token (valid 1 year)..."
kubectl create token jeshica -n kube-system --duration=8760h

# Step 8: Output the Service Information for accessing the Dashboard
echo "[+] Dashboard Service Info:"
kubectl get svc k8s-dash-svc -n kubernetes-dashboard

# Step 9: Fetch the NodePort dynamically
NODE_PORT=$(kubectl get svc k8s-dash-svc -n kubernetes-dashboard -o=jsonpath='{.spec.ports[0].nodePort}')
MASTER_NODE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Final Step: Access the Dashboard
echo -e "\n[!] Access the dashboard using: https://$MASTER_NODE_IP:$NODE_PORT\n"
