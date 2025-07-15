# kind Cluster Setup

## Prerequisites
- Docker Desktop (running)
- kind (https://kind.sigs.k8s.io/)
- bash (default on macOS and Linux)

## Cluster Topology
- Uses `kind-example-config.yaml` (1 control-plane, 2 workers)

## Create the Cluster
```sh
./create-kind-cluster.sh
```

## Delete the Cluster
```sh
kind delete cluster --name sre-demo
```

## Customization
- Edit `kind-example-config.yaml` to change node roles, add ports, or customize the cluster.
- See [kind docs](https://kind.sigs.k8s.io/docs/user/configuration/) for more options. 