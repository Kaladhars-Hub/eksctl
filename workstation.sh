#!/bin/bash

# --- 1. Disk Management ---
# We grow the partition to make room for Docker images and K8s logs
echo "Expanding Disk Space..."
sudo growpart /dev/nvme0n1 4
sudo lvextend -L +30G /dev/mapper/RootVG-varVol
sudo xfs_growfs /var

# --- 2. Docker Installation ---
echo "Installing Docker..."
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# --- 3. Kubernetes Tools (kubectl & eksctl) ---
echo "Installing Kubectl and eksctl..."
# Install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.34.2/2025-11-13/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/

echo "Setup Complete! Please log out and log back in for Docker permissions to apply."