#!/bin/bash
set -e

# Update system
yum update -y

# Install required packages
yum install -y \
  kubectl \
  awscli \
  jq \
  git \
  vim \
  htop \
  unzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Configure kubectl for EKS
aws eks update-kubeconfig --region ${region} --name ${cluster_name}

# Create kubectl alias for easier access
echo 'alias k="kubectl"' >> /home/ec2-user/.bashrc
echo 'alias kg="kubectl get"' >> /home/ec2-user/.bashrc
echo 'alias kd="kubectl describe"' >> /home/ec2-user/.bashrc
echo 'alias kl="kubectl logs"' >> /home/ec2-user/.bashrc

# Set up kubectl completion
kubectl completion bash >> /home/ec2-user/.bashrc

# Create useful scripts
cat > /home/ec2-user/eks-access.sh << 'EOF'
#!/bin/bash
# Script to access EKS cluster
echo "Connecting to EKS cluster: ${cluster_name}"
echo "Current context:"
kubectl config current-context
echo ""
echo "Available namespaces:"
kubectl get namespaces
echo ""
echo "Available pods:"
kubectl get pods --all-namespaces
EOF

chmod +x /home/ec2-user/eks-access.sh

# Set ownership
chown -R ec2-user:ec2-user /home/ec2-user/

# Create systemd service for kubectl proxy (optional)
cat > /etc/systemd/system/kubectl-proxy.service << EOF
[Unit]
Description=Kubectl Proxy
After=network.target

[Service]
Type=simple
User=ec2-user
ExecStart=/usr/bin/kubectl proxy --address=0.0.0.0 --port=8001 --accept-hosts='.*'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start kubectl proxy service
systemctl enable kubectl-proxy
systemctl start kubectl-proxy

echo "Bastion host setup completed successfully!"
echo "Cluster: ${cluster_name}"
echo "Region: ${region}" 