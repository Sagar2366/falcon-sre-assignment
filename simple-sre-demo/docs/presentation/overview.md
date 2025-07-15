# SRE Technical Assessment – Solution Overview

---

## Slide 1: Introduction & Objectives
- Project goal: Cloud-native SRE demo
- Key requirements: automation, reliability, observability, cost/security

---

## Slide 2: Architecture Overview
- Lambda cost notifier (AWS Cost Explorer + SES)
- Kubernetes demo app (nginx)
- kind/EKS cluster
- Diagram reference

---

## Slide 3: Infrastructure as Code
- Terraform for Lambda, IAM, SES, CloudWatch
- Helm for Kubernetes app
- Reusable modules/boilerplate

---

## Slide 4: SRE Practices
- SLOs for Lambda and app
- Monitoring: CloudWatch, Prometheus, metrics-server
- Runbooks and incident response

---

## Slide 5: Security & Cost Awareness
- IAM least privilege
- SES verification
- Cost tracking and alerting
- Tagging strategy (if any)

---

## Slide 6: Reliability & Scalability
- Readiness/liveness probes
- HPA for autoscaling
- Self-healing and recovery

---

## Slide 7: Lessons & Improvements
- Design decisions and trade-offs
- Potential enhancements (CI/CD, dashboards, chaos testing)
- Challenges faced
- Q&A 