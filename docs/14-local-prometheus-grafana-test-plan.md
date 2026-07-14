# Local Prometheus and Grafana Test Plan

This document validates metrics collection in the local Docker/WSL CKA Kubernetes cluster before moving the platform to AWS EKS.

## Goal

Install Prometheus and Grafana locally, enable app `ServiceMonitor` resources, and confirm Prometheus can scrape the church application `/metrics` endpoints.

This local test covers:

- Prometheus Operator CRDs
- Prometheus server
- Grafana
- node-exporter
- kube-state-metrics
- application `ServiceMonitor` resources
- backend `/metrics` scraping

It does not test AWS-specific observability such as ALB CloudWatch metrics, IRSA, Route 53, ACM, or WAF.

## Prerequisites

The church app must already be deployed and working in the local cluster.

```bash
kubectl get pods -n church-prod
kubectl get svc -n church-prod
```

Helm must be installed and available in the same terminal where `kubectl` works.

```bash
helm version
kubectl get nodes
```

## Install monitoring stack

```bash
chmod +x scripts/local-test/*.sh
./scripts/local-test/install-monitoring-local.sh
```

This installs the `kube-prometheus-stack` chart into the `monitoring` namespace using local values.

## Enable app metrics scraping

After Prometheus Operator CRDs are installed, enable `ServiceMonitor` resources for the app.

```bash
./scripts/local-test/enable-app-metrics-local.sh
```

Expected resources:

```bash
kubectl get servicemonitor -n church-prod
```

Expected output includes:

- `auth-service`
- `church-core-service`
- `document-service`

## Test Prometheus API

```bash
./scripts/local-test/test-prometheus-local.sh
```

Useful PromQL queries:

```promql
up
app_info
http_requests_total
http_request_duration_seconds_count
process_resident_memory_bytes
```

## Open Prometheus UI

Run in a dedicated terminal:

```bash
./scripts/local-test/port-forward-prometheus-local.sh
```

Open:

```text
http://localhost:9090/targets
```

Confirm the app targets are up.

## Open Grafana UI

Run in a dedicated terminal:

```bash
./scripts/local-test/port-forward-grafana-local.sh
```

Open:

```text
http://localhost:3000
```

Local credentials:

```text
username: admin
password: admin
```

## Grafana checks

Start with built-in dashboards from kube-prometheus-stack:

- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace
- Kubernetes / Compute Resources / Pod
- Node Exporter dashboards

Then create a simple app dashboard using these queries:

```promql
sum by (service) (rate(http_requests_total[5m]))
```

```promql
sum by (service, status_code) (rate(http_requests_total[5m]))
```

```promql
histogram_quantile(0.95, sum by (service, le) (rate(http_request_duration_seconds_bucket[5m])))
```

```promql
process_resident_memory_bytes{service=~"auth-service|church-core-service|document-service"}
```

## Portfolio screenshots

Capture:

- `kubectl get pods -n monitoring`
- `kubectl get servicemonitor -n church-prod`
- Prometheus targets page showing app targets up
- Prometheus query for `app_info`
- Grafana Kubernetes cluster dashboard
- Grafana app request-rate panel

## Cleanup

To remove monitoring only:

```bash
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```

To disable app ServiceMonitors without removing the app:

```bash
helm upgrade church-app helm/apps/church-app \
  --namespace church-prod \
  --reuse-values \
  --set serviceMonitor.enabled=false
```
