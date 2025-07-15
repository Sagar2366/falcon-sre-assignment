# SRE Assessment - Troubleshooting Guide

## Overview

This guide provides solutions for common issues encountered during the setup and operation of the SRE Assessment project.

## Infrastructure Issues

### Terraform Issues

#### 1. State Lock Issues

**Symptoms**: `Error acquiring the state lock`

**Solution**:
```bash
# Force unlock state (use with caution)
terraform force-unlock <lock-id>

# Check for stale locks
aws dynamodb describe-table --table-name terraform-state-lock
```

#### 2. Resource Import Issues

**Symptoms**: `Resource not found` or `Resource already exists`

**Solution**:
```bash
# Import existing resources
terraform import aws_eks_cluster.main <cluster-id>
terraform import aws_lambda_function.cost_reporter <function-name>

# Check existing resources
aws eks describe-cluster --name sre-assessment-dev
aws lambda get-function --function-name sre-assessment-cost-reporter
```

#### 3. Provider Version Conflicts

**Symptoms**: `Provider version constraint` errors

**Solution**:
```bash
# Update provider versions
terraform init -upgrade

# Check provider versions
terraform version
```

### EKS Cluster Issues

#### 1. Cluster Access Issues

**Symptoms**: `Unable to connect to the server`

**Solution**:
```bash
# Update kubeconfig
aws eks update-kubeconfig --name sre-assessment-dev --region us-west-2

# Verify cluster status
aws eks describe-cluster --name sre-assessment-dev

# Check cluster endpoint
kubectl cluster-info
```

#### 2. Node Group Issues

**Symptoms**: Pods stuck in `Pending` state

**Solution**:
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name sre-assessment-dev --nodegroup-name sre-assessment-dev-node-group

# Check node capacity
kubectl get nodes
kubectl describe node <node-name>

# Scale node group if needed
aws eks update-nodegroup-config \
  --cluster-name sre-assessment-dev \
  --nodegroup-name sre-assessment-dev-node-group \
  --scaling-config minSize=2,maxSize=5
```

#### 3. Control Plane Issues

**Symptoms**: API server timeouts or errors

**Solution**:
```bash
# Check control plane logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/sre-assessment-dev"

# Verify network connectivity
kubectl get nodes
kubectl get pods --all-namespaces

# Check security groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=sre-assessment-dev-eks*"
```

### Lambda Function Issues

#### 1. Function Execution Errors

**Symptoms**: Lambda function fails or times out

**Solution**:
```bash
# Check Lambda logs
aws logs tail /aws/lambda/sre-assessment-cost-reporter --follow

# Test function manually
aws lambda invoke --function-name sre-assessment-cost-reporter response.json

# Check function configuration
aws lambda get-function --function-name sre-assessment-cost-reporter
```

#### 2. Permission Issues

**Symptoms**: `AccessDenied` errors

**Solution**:
```bash
# Check IAM role
aws iam get-role --role-name sre-assessment-cost-reporter-lambda-role

# Check role policies
aws iam list-attached-role-policies --role-name sre-assessment-cost-reporter-lambda-role

# Test permissions
aws sts get-caller-identity
```

#### 3. SES Configuration Issues

**Symptoms**: Email delivery failures

**Solution**:
```bash
# Verify SES configuration
aws ses get-send-quota
aws ses list-identities

# Check SES verification status
aws ses get-identity-verification-attributes --identities admin@crowdstrike.com
```

## Application Issues

### Kubernetes Deployment Issues

#### 1. Pod Startup Issues

**Symptoms**: Pods in `CrashLoopBackOff` or `Pending` state

**Solution**:
```bash
# Check pod events
kubectl describe pod <pod-name> -n sre-app

# Check pod logs
kubectl logs <pod-name> -n sre-app

# Check resource limits
kubectl top pods -n sre-app
kubectl describe node <node-name>
```

#### 2. Image Pull Issues

**Symptoms**: `ImagePullBackOff` errors

**Solution**:
```bash
# Check image availability
docker pull nginx:1.25

# Verify ECR access
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-west-2.amazonaws.com

# Check image pull secrets
kubectl get secrets -n sre-app
kubectl describe pod <pod-name> -n sre-app
```

#### 3. Service Connectivity Issues

**Symptoms**: Services not accessible

**Solution**:
```bash
# Check service status
kubectl get services -n sre-app
kubectl describe service <service-name> -n sre-app

# Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- http://<service-name>.<namespace>.svc.cluster.local

# Check endpoints
kubectl get endpoints -n sre-app
```

### ArgoCD Issues

#### 1. Application Sync Failures

**Symptoms**: Applications not syncing or sync errors

**Solution**:
```bash
# Check ArgoCD status
kubectl get pods -n argocd
kubectl logs -n argocd deployment/argocd-application-controller

# Check application status
argocd app list
argocd app get <app-name>

# Force sync
argocd app sync <app-name>
```

#### 2. Repository Access Issues

**Symptoms**: Git repository connection failures

**Solution**:
```bash
# Check repository credentials
kubectl get secrets -n argocd
kubectl describe secret <repo-secret> -n argocd

# Test repository access
argocd repo list
argocd repo test <repo-url>
```

#### 3. RBAC Issues

**Symptoms**: Permission denied errors

**Solution**:
```bash
# Check RBAC configuration
kubectl get clusterrolebindings
kubectl get rolebindings -n argocd

# Check user permissions
kubectl auth can-i <verb> <resource> -n <namespace>
```

## Monitoring Issues

### CloudWatch Issues

#### 1. Missing Metrics

**Symptoms**: Empty dashboards or missing data

**Solution**:
```bash
# Check metric namespace
aws cloudwatch list-metrics --namespace AWS/EKS

# Check metric data
aws cloudwatch get-metric-statistics \
  --namespace AWS/EKS \
  --metric-name cluster_failed_node_count \
  --dimensions Name=ClusterName,Value=sre-assessment-dev \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average
```

#### 2. Alarm Issues

**Symptoms**: Alarms not triggering or false positives

**Solution**:
```bash
# Check alarm configuration
aws cloudwatch describe-alarms --alarm-names-prefix sre-assessment-dev

# Test alarm manually
aws cloudwatch set-alarm-state \
  --alarm-name sre-assessment-dev-lambda-errors \
  --state-value ALARM \
  --state-reason "Testing alarm delivery"

# Check alarm history
aws cloudwatch describe-alarm-history --alarm-name sre-assessment-dev-lambda-errors
```

### Application Monitoring Issues

#### 1. Custom Metrics Not Appearing

**Symptoms**: Application metrics not showing in CloudWatch

**Solution**:
```bash
# Check custom metric publishing
aws cloudwatch put-metric-data \
  --namespace SREAssessment \
  --metric-data MetricName=TestMetric,Value=1

# Verify metric exists
aws cloudwatch list-metrics --namespace SREAssessment
```

#### 2. Log Collection Issues

**Symptoms**: Application logs not appearing in CloudWatch

**Solution**:
```bash
# Check log group
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/sre-assessment-dev"

# Check log streams
aws logs describe-log-streams --log-group-name "/aws/eks/sre-assessment-dev/cluster"

# Test log publishing
aws logs put-log-events \
  --log-group-name "/aws/eks/sre-assessment-dev/test" \
  --log-stream-name "test-stream" \
  --log-events timestamp=1640995200000,message="Test log entry"
```

## Security Issues

### IAM Issues

#### 1. Permission Denied Errors

**Symptoms**: `AccessDenied` or `UnauthorizedOperation`

**Solution**:
```bash
# Check current identity
aws sts get-caller-identity

# Check user permissions
aws iam get-user
aws iam list-attached-user-policies --user-name <username>

# Test specific permissions
aws eks describe-cluster --name sre-assessment-dev
```

#### 2. Role Assumption Issues

**Symptoms**: Cannot assume roles or cross-account access

**Solution**:
```bash
# Check role trust policy
aws iam get-role --role-name <role-name>
aws iam get-role-policy --role-name <role-name> --policy-name <policy-name>

# Test role assumption
aws sts assume-role --role-arn <role-arn> --role-session-name test-session
```

### Network Security Issues

#### 1. VPC Connectivity Issues

**Symptoms**: Cannot connect to resources in VPC

**Solution**:
```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids <vpc-id>
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup google.com
```

#### 2. Security Group Issues

**Symptoms**: Network access blocked

**Solution**:
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Check network ACLs
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=<vpc-id>"

# Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- http://<service-url>
```

## Cost Optimization Issues

### Cost Monitoring Issues

#### 1. Cost Data Not Available

**Symptoms**: Cost Explorer shows no data or delayed data

**Solution**:
```bash
# Check Cost Explorer permissions
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics UnblendedCost

# Check billing alerts
aws budgets describe-budgets --account-id <account-id>
```

#### 2. Budget Alerts Not Working

**Symptoms**: Budget alerts not triggering

**Solution**:
```bash
# Check budget configuration
aws budgets describe-budgets --account-id <account-id>

# Check SNS topic
aws sns list-topics
aws sns list-subscriptions-by-topic --topic-arn <topic-arn>

# Test notification
aws sns publish --topic-arn <topic-arn> --message "Test notification"
```

### Resource Optimization Issues

#### 1. Auto-scaling Not Working

**Symptoms**: Resources not scaling up/down

**Solution**:
```bash
# Check HPA status
kubectl get hpa -n sre-app
kubectl describe hpa <hpa-name> -n sre-app

# Check metrics server
kubectl top pods -n sre-app
kubectl top nodes

# Check cluster autoscaler
kubectl get pods -n kube-system | grep cluster-autoscaler
kubectl logs -n kube-system deployment/cluster-autoscaler
```

#### 2. Spot Instance Issues

**Symptoms**: Spot instances not launching or frequent interruptions

**Solution**:
```bash
# Check spot instance requests
aws ec2 describe-spot-instance-requests

# Check spot price history
aws ec2 describe-spot-price-history \
  --instance-types t3.medium \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z

# Check node group configuration
aws eks describe-nodegroup --cluster-name sre-assessment-dev --nodegroup-name sre-assessment-dev-node-group
```

## Performance Issues

### Application Performance

#### 1. High Latency

**Symptoms**: Slow response times

**Solution**:
```bash
# Check resource usage
kubectl top pods -n sre-app
kubectl top nodes

# Check application logs
kubectl logs deployment/sre-app -n sre-app --tail=100

# Check network performance
kubectl run test-pod --image=busybox --rm -it --restart=Never -- ping <service-url>
```

#### 2. High Memory Usage

**Symptoms**: OOMKilled pods or memory pressure

**Solution**:
```bash
# Check memory usage
kubectl top pods -n sre-app
kubectl describe node <node-name>

# Check memory limits
kubectl get pods -n sre-app -o yaml | grep -A 5 resources:

# Scale up memory limits
kubectl patch deployment sre-app -n sre-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"memory":"512Mi"},"limits":{"memory":"1Gi"}}}]}}}}'
```

#### 3. High CPU Usage

**Symptoms**: Slow performance due to CPU pressure

**Solution**:
```bash
# Check CPU usage
kubectl top pods -n sre-app
kubectl top nodes

# Scale horizontally
kubectl scale deployment sre-app -n sre-app --replicas=5

# Check for CPU-intensive operations
kubectl logs deployment/sre-app -n sre-app | grep -i cpu
```

## Debugging Commands

### General Debugging

```bash
# Check all resources
kubectl get all --all-namespaces

# Check events
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp

# Check resource quotas
kubectl get resourcequota --all-namespaces

# Check persistent volumes
kubectl get pv,pvc --all-namespaces
```

### Network Debugging

```bash
# Test DNS resolution
kubectl run debug --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Test service connectivity
kubectl run debug --image=busybox --rm -it --restart=Never -- wget -O- http://<service-url>

# Check network policies
kubectl get networkpolicy --all-namespaces
```

### Storage Debugging

```bash
# Check storage classes
kubectl get storageclass

# Check persistent volumes
kubectl get pv,pvc --all-namespaces

# Check volume mounts
kubectl describe pod <pod-name> -n <namespace>
```

## Common Error Messages

### Terraform Errors

1. **`Error: Invalid provider configuration`**
   - Solution: Run `terraform init -upgrade`

2. **`Error: Resource not found`**
   - Solution: Import existing resources or check resource names

3. **`Error: Insufficient permissions`**
   - Solution: Check IAM permissions and roles

### Kubernetes Errors

1. **`ImagePullBackOff`**
   - Solution: Check image availability and pull secrets

2. **`CrashLoopBackOff`**
   - Solution: Check application logs and resource limits

3. **`Pending` pods**
   - Solution: Check node capacity and resource requests

### AWS Errors

1. **`AccessDenied`**
   - Solution: Check IAM permissions and policies

2. **`ResourceLimitExceeded`**
   - Solution: Request service limits increase

3. **`InvalidParameterValue`**
   - Solution: Check parameter values and formats

## Getting Help

### Documentation Resources

1. **Official Documentation**
   - [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
   - [Terraform Documentation](https://www.terraform.io/docs)
   - [Kubernetes Documentation](https://kubernetes.io/docs/)
   - [ArgoCD Documentation](https://argoproj.github.io/argo-cd/)

2. **Community Resources**
   - [AWS Developer Forums](https://forums.aws.amazon.com/)
   - [Terraform Community](https://discuss.hashicorp.com/)
   - [Kubernetes Slack](https://slack.k8s.io/)

### Support Channels

1. **Internal Support**
   - SRE team Slack channel
   - On-call engineer rotation
   - Escalation procedures

2. **External Support**
   - AWS Support (if applicable)
   - Terraform Enterprise support
   - Community forums

## Conclusion

This troubleshooting guide covers the most common issues encountered with the SRE Assessment project. For issues not covered here, refer to the official documentation or contact the SRE team.

Remember to:
- Always check logs first
- Use systematic debugging approach
- Document solutions for future reference
- Update runbooks with new solutions 