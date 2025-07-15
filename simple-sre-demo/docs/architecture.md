# Architecture Overview

This system consists of two main components:

- **AWS Lambda Cost Notifier:** Queries AWS Cost Explorer daily and sends a summary email via SES.
- **Kubernetes Demo App:** A simple containerized app (nginx) deployed on a kind (or EKS) cluster, with autoscaling and health checks.

## Diagram

```mermaid
flowchart TD
  User["User"]
  SES["Amazon SES<br/>Email Service"]
  Lambda["AWS Lambda<br/>Cost Notifier"]
  CostExplorer["AWS Cost Explorer"]
  K8sApp["Kubernetes Demo App<br/>(nginx, Flask, etc.)"]
  HPA["Horizontal Pod Autoscaler"]
  kind[("kind/EKS Cluster")]

  User -- receives daily cost email --> SES
  SES -- sends email --> User
  Lambda -- queries cost --> CostExplorer
  Lambda -- sends summary --> SES
  K8sApp -- exposes service --> kind
  HPA -- scales --> K8sApp
  K8sApp -- metrics --> HPA
  User -- accesses app --> K8sApp
  kind -- runs --> K8sApp

  subgraph AWS
    Lambda
    SES
    CostExplorer
  end

  subgraph Kubernetes
    kind
    K8sApp
    HPA
  end
```

## Component Interactions
- The Lambda function runs daily, queries AWS Cost Explorer, and sends a cost summary email via SES.
- The demo app is deployed on Kubernetes, exposed via a Service, and automatically scaled by HPA based on CPU usage.
- Users can access the app via the kind/EKS cluster, and receive cost reports via email. 