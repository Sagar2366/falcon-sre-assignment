# SRE Runbooks - Operational Procedures

## Overview

This document contains runbooks for common operational procedures and incident response for the SRE Assessment project.

## Incident Response Procedures

### 1. Service Down (P0)

**Symptoms**: Service unavailable, health checks failing, 5xx errors

**Immediate Actions**:
1. **Acknowledge Alert** (5 minutes)
   - Respond to alert in monitoring system
   - Update status page to "Investigating"

2. **Initial Assessment** (10 minutes)
   ```bash
   # Check service health
   kubectl get pods -n <namespace>
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   
   # Check infrastructure
   aws eks describe-cluster --name <cluster-name>
   kubectl get nodes
   ```

3. **Quick Fixes** (15 minutes)
   - Restart failing pods: `kubectl rollout restart deployment <deployment>`
   - Scale up if needed: `kubectl scale deployment <deployment> --replicas=3`
   - Check resource limits: `kubectl top pods`

4. **Escalation** (30 minutes)
   - If service still down, escalate to senior engineer
   - Notify stakeholders
   - Consider rollback to previous version

**Resolution Steps**:
1. Identify root cause
2. Implement fix
3. Verify service health
4. Update status page
5. Document incident

### 2. High Error Rate (P0)

**Symptoms**: Error rate > 1%, 4xx/5xx responses increasing

**Immediate Actions**:
1. **Check Error Patterns** (5 minutes)
   ```bash
   # Check recent logs
   kubectl logs -f deployment/<deployment> --tail=100
   
   # Check metrics
   kubectl top pods
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

2. **Identify Error Types** (10 minutes)
   - Database connection errors
   - Memory/CPU pressure
   - Network timeouts
   - Application exceptions

3. **Quick Mitigation** (15 minutes)
   - Scale up resources if needed
   - Restart problematic pods
   - Check external dependencies

4. **Root Cause Analysis** (30 minutes)
   - Review recent deployments
   - Check configuration changes
   - Analyze error logs

**Resolution Steps**:
1. Fix underlying issue
2. Deploy fix
3. Monitor error rate
4. Update monitoring if needed

### 3. High Latency (P1)

**Symptoms**: P95 latency > 200ms, slow response times

**Investigation Steps**:
1. **Check Resource Usage** (5 minutes)
   ```bash
   kubectl top pods
   kubectl top nodes
   ```

2. **Analyze Performance** (10 minutes)
   - Check CPU/memory utilization
   - Review database query performance
   - Check network latency

3. **Optimization Actions** (15 minutes)
   - Scale up resources
   - Optimize database queries
   - Add caching if appropriate

4. **Long-term Fixes** (1 hour)
   - Implement performance improvements
   - Add monitoring for slow queries
   - Optimize application code

### 4. Cost Exceeded (P1)

**Symptoms**: Monthly cost > budget, unusual spending patterns

**Investigation Steps**:
1. **Review Cost Breakdown** (10 minutes)
   ```bash
   # Check AWS Cost Explorer
   aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31
   
   # Check resource utilization
   kubectl top pods --all-namespaces
   ```

2. **Identify Cost Drivers** (15 minutes)
   - High resource utilization
   - Unused resources
   - Inefficient instance types
   - Data transfer costs

3. **Optimization Actions** (30 minutes)
   - Scale down unused resources
   - Switch to spot instances
   - Implement auto-scaling
   - Right-size instances

4. **Prevention Measures** (1 hour)
   - Set up cost alerts
   - Implement resource tagging
   - Create cost optimization policies

## Infrastructure Runbooks

### 1. EKS Cluster Issues

#### Node Group Scaling Issues

**Symptoms**: Pods pending, insufficient resources

**Resolution**:
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name <cluster> --nodegroup-name <nodegroup>

# Scale node group
aws eks update-nodegroup-config --cluster-name <cluster> --nodegroup-name <nodegroup> --scaling-config minSize=2,maxSize=5

# Check pod scheduling
kubectl get pods --all-namespaces -o wide
kubectl describe pod <pending-pod>
```

#### Cluster Control Plane Issues

**Symptoms**: API server errors, kubectl timeouts

**Resolution**:
```bash
# Check cluster status
aws eks describe-cluster --name <cluster>

# Check control plane logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/<cluster>"

# Verify network connectivity
kubectl get nodes
kubectl get pods --all-namespaces
```

### 2. Lambda Function Issues

#### Cost Reporter Failures

**Symptoms**: No daily cost reports, Lambda errors

**Investigation**:
```bash
# Check Lambda logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/cost-reporter"

# Check Lambda metrics
aws cloudwatch get-metric-statistics --namespace AWS/Lambda --metric-name Errors --dimensions Name=FunctionName,Value=cost-reporter

# Test Lambda manually
aws lambda invoke --function-name cost-reporter response.json
```

**Common Fixes**:
1. **SES Configuration**: Verify email permissions
2. **Cost Explorer Access**: Check IAM permissions
3. **Memory/Timeout**: Increase Lambda configuration
4. **VPC Issues**: Check VPC endpoints

### 3. ArgoCD Issues

#### Application Sync Failures

**Symptoms**: Applications not syncing, sync errors

**Resolution**:
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

#### Repository Access Issues

**Symptoms**: Git repository connection failures

**Resolution**:
1. Check repository credentials
2. Verify network connectivity
3. Update repository URL if needed
4. Check SSH/HTTPS configuration

## Application Runbooks

### 1. Deployment Issues

#### Rolling Update Failures

**Symptoms**: Deployment stuck, pods not ready

**Resolution**:
```bash
# Check deployment status
kubectl rollout status deployment/<deployment>

# Check pod events
kubectl describe deployment <deployment>
kubectl get events --sort-by=.metadata.creationTimestamp

# Rollback if needed
kubectl rollout undo deployment/<deployment>
```

#### Image Pull Issues

**Symptoms**: ImagePullBackOff errors

**Resolution**:
```bash
# Check image availability
docker pull <image:tag>

# Verify ECR access
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com

# Check image pull secrets
kubectl get secrets
kubectl describe pod <pod-name>
```

### 2. Resource Issues

#### Memory Pressure

**Symptoms**: OOMKilled pods, high memory usage

**Resolution**:
```bash
# Check memory usage
kubectl top pods
kubectl describe node <node>

# Scale up resources
kubectl patch deployment <deployment> -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"memory":"512Mi"},"limits":{"memory":"1Gi"}}}]}}}}'

# Check for memory leaks
kubectl logs <pod-name> | grep -i memory
```

#### CPU Pressure

**Symptoms**: High CPU usage, slow response times

**Resolution**:
```bash
# Check CPU usage
kubectl top pods
kubectl top nodes

# Scale horizontally
kubectl scale deployment <deployment> --replicas=5

# Check for CPU-intensive operations
kubectl logs <pod-name> | grep -i cpu
```

## Monitoring and Alerting Runbooks

### 1. Alert Investigation

#### High Error Rate Alert

**Investigation Steps**:
1. Check application logs for error patterns
2. Review recent deployments
3. Check external dependencies
4. Analyze error distribution

**Common Causes**:
- Database connection issues
- Memory pressure
- Network timeouts
- Configuration errors

#### High Latency Alert

**Investigation Steps**:
1. Check resource utilization
2. Review database query performance
3. Check network latency
4. Analyze application bottlenecks

**Common Causes**:
- High CPU/memory usage
- Slow database queries
- Network congestion
- Inefficient code paths

### 2. Dashboard Issues

#### Missing Metrics

**Symptoms**: Empty dashboards, missing data points

**Resolution**:
1. Check metric collection configuration
2. Verify CloudWatch permissions
3. Check custom metric publishing
4. Review metric filters

#### Dashboard Performance

**Symptoms**: Slow dashboard loading, timeouts

**Resolution**:
1. Optimize query time ranges
2. Reduce metric resolution
3. Use CloudWatch Insights for complex queries
4. Implement metric aggregation

## Security Runbooks

### 1. Access Issues

#### IAM Permission Denials

**Symptoms**: Access denied errors, permission issues

**Resolution**:
```bash
# Check IAM roles
aws iam get-role --role-name <role-name>

# Check role policies
aws iam list-attached-role-policies --role-name <role-name>

# Test permissions
aws sts get-caller-identity
```

#### Kubernetes RBAC Issues

**Symptoms**: Permission denied in kubectl

**Resolution**:
```bash
# Check user permissions
kubectl auth can-i <verb> <resource>

# Check role bindings
kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings

# Check service account
kubectl get serviceaccount <serviceaccount> -n <namespace>
```

### 2. Security Incidents

#### Unauthorized Access

**Symptoms**: Unknown logins, suspicious activity

**Response**:
1. Immediately revoke access
2. Check audit logs
3. Rotate credentials
4. Investigate source
5. Update security policies

#### Data Breach

**Symptoms**: Unauthorized data access, suspicious data transfers

**Response**:
1. Isolate affected systems
2. Preserve evidence
3. Notify security team
4. Assess data exposure
5. Implement containment measures

## Cost Optimization Runbooks

### 1. Resource Optimization

#### Right-sizing Instances

**Process**:
1. Analyze resource utilization
2. Identify over-provisioned resources
3. Test with smaller instances
4. Implement changes gradually
5. Monitor performance impact

#### Spot Instance Management

**Process**:
1. Identify suitable workloads
2. Configure spot instance groups
3. Implement fallback mechanisms
4. Monitor spot instance availability
5. Optimize bidding strategies

### 2. Cost Monitoring

#### Budget Alerts

**Response**:
1. Review cost breakdown
2. Identify cost drivers
3. Implement immediate savings
4. Plan long-term optimization
5. Update budget forecasts

#### Unusual Spending

**Investigation**:
1. Check recent deployments
2. Review resource changes
3. Analyze cost trends
4. Identify optimization opportunities
5. Implement cost controls

## Communication Procedures

### 1. Incident Communication

#### Status Page Updates

**Template**:
```
[INVESTIGATING] We are investigating reports of service issues.
[IDENTIFIED] We have identified the issue and are working on a fix.
[MONITORING] We have implemented a fix and are monitoring the situation.
[RESOLVED] The issue has been resolved.
```

#### Stakeholder Updates

**Template**:
```
Subject: [P0/P1] Service Issue - <Brief Description>

Impact: <What's affected>
Timeline: <When it started, expected resolution>
Status: <Current status>
Next Update: <When next update will be provided>
```

### 2. Post-Incident Review

#### Incident Documentation

**Template**:
```
Incident ID: <ID>
Date: <Date>
Duration: <Duration>
Severity: <P0/P1/P2>
Root Cause: <Root cause>
Resolution: <How it was resolved>
Lessons Learned: <What we learned>
Action Items: <What we'll do differently>
```

## Preventive Measures

### 1. Regular Maintenance

#### Weekly Tasks
- Review alert thresholds
- Check resource utilization
- Update runbooks
- Review security logs

#### Monthly Tasks
- SLO review and updates
- Cost optimization review
- Security assessment
- Performance analysis

#### Quarterly Tasks
- Comprehensive architecture review
- Disaster recovery testing
- Security penetration testing
- Capacity planning

### 2. Proactive Monitoring

#### Health Checks
- Service availability monitoring
- Performance trend analysis
- Capacity planning
- Security vulnerability scanning

#### Automation
- Automated scaling policies
- Self-healing mechanisms
- Automated backups
- Security compliance checks

## Conclusion

These runbooks provide a comprehensive framework for handling common operational issues and maintaining system reliability. Regular updates and practice drills ensure the team is prepared for real incidents. 