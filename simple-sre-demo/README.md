# Simple SRE Demo

This project is a minimal demonstration of SRE practices using:
- A simple AWS Lambda function (Python)
- A basic Kubernetes Helm chart for a demo app (with metrics-server as a dependency)
- A GitHub Actions workflow for CI/CD
- Local deployment using [kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker)

---

## Prerequisites
- Docker Desktop (running)
- kind (https://kind.sigs.k8s.io/)
- bash (default on macOS and Linux)
- A running Kubernetes cluster (kind, EKS, etc.)
- kubectl (configured for your cluster)
- Helm (https://helm.sh/)
- AWS CLI (for Lambda deployment)
- Python 3.x (for Lambda local test)

---

## Monitoring Stack: kube-prometheus-stack (Required for PrometheusRule Alerts)

To enable PrometheusRule alerts and full cluster monitoring, you must install the [kube-prometheus-stack Helm chart](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) **before** deploying this demo app.

### Install kube-prometheus-stack via Helm
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```
- This will install the Prometheus Operator, Prometheus, Alertmanager, Grafana, and all required CRDs (including PrometheusRule).
- See [kube-prometheus-stack docs](https://github.com/prometheus-operator/kube-prometheus) for more details.

> **Note:** If you do not install this stack, the PrometheusRule resource in the demo app will fail to install. You can disable or remove the alert if not using Prometheus.

---

## Metrics Server (Automatic)
- The demo app Helm chart now includes [metrics-server](https://artifacthub.io/packages/helm/metrics-server/metrics-server) as a dependency.
- When you install the chart, metrics-server will be installed automatically (unless you disable it).
- This enables HPA and resource metrics out-of-the-box for kind and EKS.
- To customize or disable metrics-server, see `helm-chart/README.md` for details.

---

## PrometheusRule Alerting (Optional)
- The Helm chart includes a sample `PrometheusRule` for alerting on high error rates.
- **You must install the Prometheus Operator (kube-prometheus-stack) before using this feature.**
- If the CRD is not present, you will get an error like:
  > no matches for kind "PrometheusRule" in version "monitoring.coreos.com/v1"

### Install Prometheus Operator (Helm)
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```
- If you do not want to use PrometheusRule, you can comment out or remove `helm-chart/templates/prometheus-alert.yaml` from the chart.
- For more info, see [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).

---

## Helm Chart Deployment Steps

**Before installing or upgrading the chart, add the metrics-server repo and update dependencies:**

```sh
# Add the metrics-server Helm repo (required for dependency resolution)
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Build chart dependencies
cd simple-sre-demo/helm-chart
helm dependency build
```

**Then install or upgrade the demo app:**

```sh
# Install
helm install demo-app .

# Or upgrade (if already installed)
helm upgrade demo-app . -f values.yaml
```

---

## 1. Create the kind Cluster

- Uses `kind-example-config.yaml` (1 control-plane, 2 workers)
- You can customize this file for more nodes, ports, etc.

```sh
cd kind
./create-kind-cluster.sh
```

To delete the cluster:
```sh
kind delete cluster --name sre-demo
```

---

## 2. Deploy the Demo App with Helm

**Important:** Before installing, you must fetch the metrics-server dependency:
```sh
cd ../helm-chart
helm dependency build
```

Then install the app:
```sh
helm install demo-app .
```

To uninstall:
```sh
helm uninstall demo-app
```

### Horizontal Pod Autoscaler (HPA)
To enable autoscaling based on CPU:
```sh
kubectl apply -f templates/hpa.yaml
```

### Probes
This chart includes readiness and liveness probes on `/` (port 80).

---

## 3. Monitoring

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
  - metrics-server will be installed automatically with this chart.

---

## 4. Deploying to EKS
- Update your kubeconfig for EKS:
  ```sh
  aws eks update-kubeconfig --region <region> --name <cluster-name>
  ```
- Then follow the same Helm install steps as above.

---

## 5. Customization
- Edit `kind/kind-example-config.yaml` to change node roles, add ports, or customize the cluster.
- See [kind docs](https://kind.sigs.k8s.io/docs/user/configuration/) for more options.

---

## 6. Lambda Function
- See `lambda/README.md` for Lambda setup, local test, and deployment notes.

---

## 7. Terraform
- See `terraform/README.md` for infrastructure deployment, S3 backend, and cost management.

---

## 8. Documentation
- SLOs, runbooks, setup guide, and architecture diagram are in the `docs/` folder.

---

## Quick Reference
- **Create kind cluster:** `cd kind && ./create-kind-cluster.sh`
- **Build Helm dependencies:** `cd ../helm-chart && helm dependency build`
- **Deploy app:** `helm install demo-app .`
- **Enable HPA:** `kubectl apply -f templates/hpa.yaml`
- **Monitor:** `kubectl get pods`, `kubectl get hpa`, `kubectl logs <pod>`
- **Delete cluster:** `kind delete cluster --name sre-demo` 