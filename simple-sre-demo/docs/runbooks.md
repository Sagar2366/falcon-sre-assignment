# Runbooks

## Lambda: Email Not Delivered
- **Symptoms:** No cost email received, CloudWatch logs show SES errors.
- **Steps:**
  1. Check Lambda logs for SES send_email errors.
  2. Verify SES sender/recipient are verified and not in sandbox.
  3. Check SES sending limits/quota.
  4. Test SES send via AWS CLI.
  5. If persistent, open AWS Support ticket.

## Lambda: Permission Error
- **Symptoms:** Lambda logs show AccessDenied or similar errors.
- **Steps:**
  1. Check IAM role attached to Lambda.
  2. Ensure role has permissions for Cost Explorer and SES.
  3. Review recent IAM policy changes.
  4. Test permissions with AWS Policy Simulator.

## Kubernetes: Pod CrashLoopBackOff
- **Symptoms:** App pod is repeatedly restarting.
- **Steps:**
  1. Run `kubectl describe pod <pod>` for events.
  2. Check logs: `kubectl logs <pod>`.
  3. Look for readiness/liveness probe failures.
  4. Check resource limits and image version.
  5. Roll back to last known good deployment if needed.

## Kubernetes: HPA Not Scaling
- **Symptoms:** App under load, but replicas not increasing.
- **Steps:**
  1. Check HPA status: `kubectl get hpa` and `kubectl describe hpa`.
  2. Ensure metrics-server is running: `kubectl get pods -n kube-system | grep metrics-server`.
  3. Confirm CPU usage is above threshold.
  4. Check HPA YAML for correct targetRef and metrics.
  5. Review app resource requests/limits. 