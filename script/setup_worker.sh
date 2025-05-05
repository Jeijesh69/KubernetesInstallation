#!/bin/bash

set -e

echo "[1/12] Updating system..."
sudo apt update -y
sudo apt install -y git wget curl socat gnupg2 software-properties-common apt-transport-https ca-certificates

echo "[2/12] Adding Docker GPG key..."
wget -O - https://download.docker.com/linux/ubuntu/gpg > ./docker.key
gpg --no-default-keyring --keyring ./docker.gpg --import ./docker.key
gpg --no-default-keyring --keyring ./docker.gpg --export > ./docker-archive-keyring.gpg
sudo mv ./docker-archive-keyring.gpg /etc/apt/trusted.gpg.d/

echo "[3/12] Adding Docker repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt update -y
sudo apt install -y docker-ce

echo "[4/12] Installing cri-dockerd (Docker CRI shim)..."
VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//g')
wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
tar xzvf cri-dockerd-${VER}.amd64.tgz
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo mv cri-docker.service cri-docker.socket /etc/systemd/system/
sudo sed -i 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

echo "[5/12] Adding Kubernetes GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "[6/12] Adding Kubernetes repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -y

echo "[7/12] Installing Kubernetes components..."
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold docker-ce kubelet kubeadm kubectl

echo "[8/12] Enabling iptables bridge networking..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "[9/12] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "[10/12] Enabling Docker and cri-dockerd..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[11/12] Confirming versions..."
docker --version
kubeadm version
kubectl version --client

echo "[12/12] DONE: System ready for Kubernetes cluster setup."
