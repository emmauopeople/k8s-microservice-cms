# Grafana Dashboard Checklist

Grafana is used for metrics from Prometheus.

## Dashboards to create

1. EKS Cluster Overview
2. Node Resource Dashboard
3. Namespace Workload Dashboard
4. Application Service Dashboard
5. Ingress and ALB Dashboard
6. Storage/PVC Dashboard
7. Velero Backup Dashboard

## First dashboards available automatically

The kube-prometheus-stack chart includes many Kubernetes dashboards by default. Use those first for screenshots:

- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace
- Kubernetes / Compute Resources / Pod
- Kubernetes / Compute Resources / Node
- Kubernetes / Kubelet
- Node Exporter / Nodes

## Custom dashboard plan

Create a custom folder:

```text
Parish Management System
```

Add these custom dashboards:

```text
Church App Services
Church App HTTP Metrics
Church Platform Storage
Church Platform Backups
```

## Application dashboard dependencies

The app-specific HTTP dashboards require backend metrics endpoints:

```text
auth-service /metrics
church-core-service /metrics
document-service /metrics
```

Until those endpoints exist, use Kubernetes pod/deployment metrics for service health.
