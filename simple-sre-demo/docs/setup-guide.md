# Setup Guide

## Prerequisites
- Docker
- kind (Kubernetes in Docker)
- kubectl
- Helm
- AWS CLI (for Lambda deployment)
- Python 3.x (for Lambda local test)

## 1. Create the kind Cluster
```sh
cd simple-sre-demo/kind
./create-kind-cluster.sh
```

## 2. Deploy the Demo App with Helm
```sh
cd ../helm-chart
helm install demo-app .
# To enable HPA:
kubectl apply -f templates/hpa.yaml
```

## 3. Deploy the Lambda Cost Notifier
### Option 1: Manual (Console)
- Zip `lambda_function.py` and `requirements.txt`.
- Create a new Lambda in AWS Console.
- Set environment variables for SES sender/recipient.
- Attach IAM role with Cost Explorer and SES permissions.
- Set up a CloudWatch Event rule for daily trigger.

### Option 2: Terraform (Recommended for IaC)
- Use a Terraform module to deploy Lambda, IAM, and SES resources.
- (See `terraform/` directory if provided.)

## 4. Monitoring
### Kubernetes App
- **Pod status:**
  ```sh
  kubectl get pods
  kubectl describe pod <pod>
  kubectl logs <pod>
  ```
- **HPA status:**
  ```sh
  kubectl get hpa
  kubectl describe hpa demo-app-hpa
  ```
- **Metrics:**
  - Ensure `metrics-server` is running:
    ```sh
    kubectl get pods -n kube-system | grep metrics-server
    ```
  - HPA will only work if metrics-server is available.

### Lambda
- **Logs:**
  - View in AWS CloudWatch Logs (search for your Lambda function name).
- **Monitoring:**
  - Use AWS Lambda and SES dashboards for invocation and error metrics.
  - CloudWatch Alarms can be set for errors or delivery failures.

## 5. Troubleshooting
- See `docs/runbooks.md` for common issues and solutions.

## 6. Architecture Diagram
- See `docs/architecture.md` for a visual overview. 