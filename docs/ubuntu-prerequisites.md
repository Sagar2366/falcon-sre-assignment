# Ubuntu Prerequisites Installation Guide

This guide provides step-by-step instructions to install all required tools on Ubuntu 20.04 LTS or later for the SRE Technical Assessment project.

## System Requirements

- **OS**: Ubuntu 20.04 LTS or later
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: Minimum 20GB free space
- **CPU**: 2 cores minimum, 4 cores recommended

## 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Install AWS CLI

```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version

# Configure AWS credentials
aws configure
```

## 3. Install kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable and move to PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

## 4. Install Helm

```bash
# Download Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz -o helm.tar.gz

# Extract and install
tar -zxvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/

# Verify installation
helm version

# Clean up
rm helm.tar.gz
rm -rf linux-amd64
```

## 5. Install Docker (Optional - for local development)

```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
```

## 6. Install Terraform

```bash
# Download Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install Terraform
sudo apt update
sudo apt install terraform

# Verify installation
terraform --version
```

## 7. Install Additional Tools

### Git
```bash
sudo apt install -y git
```

### jq (JSON processor)
```bash
sudo apt install -y jq
```

### tree (Directory listing)
```bash
sudo apt install -y tree
```

### htop (Process monitor)
```bash
sudo apt install -y htop
```

## 8. Configure AWS EKS Access

### Install eksctl (Optional)
```bash
# Download eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# Move to PATH
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version
```

### Configure kubectl for EKS
```bash
# Update kubeconfig for your EKS cluster
aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>
```

## 9. Verify All Installations

Create a verification script:

```bash
cat > verify-installations.sh << 'EOF'
#!/bin/bash

echo "=== Verification Script ==="
echo

echo "1. AWS CLI:"
aws --version
echo

echo "2. kubectl:"
kubectl version --client
echo

echo "3. Helm:"
helm version
echo

echo "4. Terraform:"
terraform --version
echo

echo "5. Docker (if installed):"
docker --version 2>/dev/null || echo "Docker not installed"
echo

echo "6. eksctl (if installed):"
eksctl version 2>/dev/null || echo "eksctl not installed"
echo

echo "7. System Info:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo

echo "8. Available Memory:"
free -h
echo

echo "9. Available Disk Space:"
df -h /
echo

echo "=== Verification Complete ==="
EOF

chmod +x verify-installations.sh
./verify-installations.sh
```

## 10. Clone the Project

```bash
# Clone the repository
git clone <your-repository-url>
cd sre-assessment

# Make setup script executable
chmod +x scripts/setup-argocd.sh
```

## 11. Environment Setup

### Set Environment Variables
```bash
# Add to your ~/.bashrc
echo 'export AWS_DEFAULT_REGION=us-west-2' >> ~/.bashrc
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

### Create SSH Key (if needed)
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER ~/.kube
   ```

2. **AWS CLI Configuration**
   ```bash
   # Reconfigure AWS CLI
   aws configure
   ```

3. **kubectl Connection Issues**
   ```bash
   # Check cluster connection
   kubectl cluster-info
   
   # Update kubeconfig
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

4. **Helm Repository Issues**
   ```bash
   # Clear Helm cache
   helm repo remove argo prometheus-community ingress-nginx
   helm repo add argo https://argoproj.github.io/argo-helm
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   ```

### System Optimization

1. **Increase File Descriptors**
   ```bash
   echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
   echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf
   ```

2. **Enable Swap (if needed)**
   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

## Next Steps

After completing the installation:

1. **Configure AWS credentials** with appropriate permissions
2. **Set up your EKS cluster** using Terraform
3. **Run the ArgoCD setup script**:
   ```bash
   ./scripts/setup-argocd.sh
   ```

## Security Notes

- Keep your AWS credentials secure
- Regularly update packages: `sudo apt update && sudo apt upgrade`
- Use IAM roles with least privilege access
- Enable AWS CloudTrail for audit logging 