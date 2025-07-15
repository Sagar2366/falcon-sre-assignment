# Demo App Helm Chart

## Prerequisites
- A running Kubernetes cluster (kind, EKS, etc.)
- kubectl (configured for your cluster)
- Helm (https://helm.sh/)

## Monitoring Stack: kube-prometheus-stack (Required for PrometheusRule Alerts)

To enable PrometheusRule alerts and full cluster monitoring, you must install the [kube-prometheus-stack Helm chart](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) **before** deploying this chart.

### Install kube-prometheus-stack via Helm
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```
- This will install the Prometheus Operator, Prometheus, Alertmanager, Grafana, and all required CRDs (including PrometheusRule).
- See [kube-prometheus-stack docs](https://github.com/prometheus-operator/kube-prometheus) for more details.

> **Note:** If you do not install this stack, the PrometheusRule resource in this chart will fail to install. You can disable or remove the alert if not using Prometheus.

## Metrics Server Dependency
- This chart includes [metrics-server](https://artifacthub.io/packages/helm/metrics-server/metrics-server) as a dependency.
- When you install this chart, metrics-server will be installed automatically (unless you disable it).
- This enables HPA and resource metrics out-of-the-box for kind and EKS.

### Customizing metrics-server
- To override metrics-server values, create a `values.yaml` with a `metrics-server:` section, e.g.:
  ```yaml
  metrics-server:
    args:
      - --kubelet-insecure-tls
  ```
- See the [metrics-server Helm chart docs](https://artifacthub.io/packages/helm/metrics-server/metrics-server) for all options.

## PrometheusRule Alerting (Optional)
- This chart includes a sample `PrometheusRule` for alerting on high error rates.
- **You must install the Prometheus Operator (kube-prometheus-stack) before using this feature.**
- If the CRD is not present, you will get an error like:
  > no matches for kind "PrometheusRule" in version "monitoring.coreos.com/v1"

### Install Prometheus Operator (Helm)
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```

- If you do not want to use PrometheusRule, you can comment out or remove `templates/prometheus-alert.yaml` from the chart.
- For more info, see [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).

## Install on kind
**Important:** Before installing, you must fetch the metrics-server dependency:
```sh
helm dependency build
```
Then install the app:
```sh
helm install demo-app .
```

## Uninstall
```sh
helm uninstall demo-app
```

## Horizontal Pod Autoscaler (HPA)
To enable autoscaling based on CPU:
```sh
kubectl apply -f templates/hpa.yaml
```

## Probes
This chart includes readiness and liveness probes on `/` (port 80).

## Monitoring

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

## Deploying to EKS
- Update your kubeconfig for EKS:
  ```sh
  aws eks update-kubeconfig --region <region> --name <cluster-name>
  ```
- Then follow the same Helm install steps as above.

## Customization
- Edit `values.yaml` to change app or metrics-server settings.
- See [kind docs](https://kind.sigs.k8s.io/docs/user/configuration/) for cluster options. 