# Observability Plan

This project uses an in-cluster observability stack for the short-lived EKS portfolio demo.

The goal is to demonstrate production-style monitoring and logging while keeping the environment easy to destroy after screenshots, validation, and documentation are complete.

## Decision

For the portfolio demo, I run all observability components inside EKS:

- Prometheus
- Grafana
- Alertmanager
- Fluent Bit
- OpenSearch
- OpenSearch Dashboards

For a real long-running production environment, prefer managed services where possible:

- Amazon Managed Service for Prometheus or a managed Prometheus-compatible backend
- Amazon Managed Grafana
- Amazon OpenSearch Service
- Centralized log retention and snapshot policies

## Metrics architecture

```text
EKS workloads
  ↓
ServiceMonitor / PodMonitor
  ↓
Prometheus Operator
  ↓
Prometheus
  ↓
Grafana dashboards
  ↓
Alertmanager alerts
```

## Logging architecture

```text
Application containers
  ↓
Kubernetes container log files
  ↓
Fluent Bit DaemonSet
  ↓
OpenSearch
  ↓
OpenSearch Dashboards
```

The Node.js services use Pino JSON logs. Fluent Bit is configured to collect Kubernetes container logs, enrich them with Kubernetes metadata, and forward them to OpenSearch.

## Namespaces

```text
monitoring
  ├── Prometheus
  ├── Grafana
  └── Alertmanager

logging
  ├── OpenSearch
  ├── OpenSearch Dashboards
  └── Fluent Bit
```

## Demo access pattern

Initially, dashboards is not public.

I use port forwarding to access dashboards:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093:9093
kubectl -n logging port-forward svc/opensearch-dashboards 5601:5601
kubectl -n logging port-forward svc/opensearch 9200:9200
```

Later, if HTTPS dashboard access is needed, enable Ingress for:

```text
grafana.eks.gestionparoissiale.org
logs.eks.gestionparoissiale.org
```

Ingress should use:

- AWS Load Balancer Controller
- ACM certificate
- WAF association
- authentication before public exposure

## Storage and retention

Demo storage sizes:

```text
Prometheus: 10Gi, 3-day retention
Grafana: 5Gi
Alertmanager: 2Gi
OpenSearch: 20Gi
```

These values are intentionally small because the EKS environment is short-lived.

For production, increase retention and move logs/metrics to managed backends or dedicated storage.

## Apply-day prerequisites

Before syncing the monitoring app, create the Grafana admin secret:

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic grafana-admin-credentials \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<strong-password>'
```

Do not commit the real Grafana password to Git.

## Apply-day deployment order

Recommended order after the cluster and Argo CD are ready:

1. Sync OpenSearch.
2. Wait for OpenSearch to be Ready.
3. Sync OpenSearch Dashboards.
4. Sync kube-prometheus-stack.
5. Sync Fluent Bit.
6. Generate application traffic.
7. Confirm metrics in Grafana.
8. Confirm logs in OpenSearch Dashboards.

## Validation commands

```bash
kubectl get pods -n monitoring
kubectl get pods -n logging
kubectl get pvc -n monitoring
kubectl get pvc -n logging
kubectl get svc -n monitoring
kubectl get svc -n logging
```

Prometheus targets:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

Open a browser:

```text
http://localhost:9090/targets
```

Grafana:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
```

Open a browser:

```text
http://localhost:3000
```

OpenSearch Dashboards:

```bash
kubectl -n logging port-forward svc/opensearch-dashboards 5601:5601
```

Open a browser:

```text
http://localhost:5601
```

## Screenshot checklist

- Monitoring namespace pods running.
- Logging namespace pods running.
- Prometheus targets page.
- Grafana Kubernetes cluster dashboard.
- Grafana pod CPU/memory dashboard.
- Alertmanager page.
- Fluent Bit DaemonSet running on nodes.
- OpenSearch index list.
- OpenSearch Dashboards log search.
- Pino JSON application logs visible in OpenSearch Dashboards.

## Production hardening later

Before using this as a real production observability stack:

- Enable OpenSearch security and TLS.
- Use secrets for OpenSearch credentials.
- Add OpenSearch snapshots.
- Configure long-term retention policies.
- Restrict dashboard access with authentication.
- Use Ingress only with TLS and WAF.
- Consider managed Prometheus, managed Grafana, and Amazon OpenSearch Service.
