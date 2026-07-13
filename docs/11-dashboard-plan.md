# Dashboard Plan

This document defines the dashboards to build after the EKS platform is applied and the church application is running.

The goal is to know exactly what to create in Grafana and OpenSearch Dashboards before the apply day starts.

## Dashboard tools

```text
Metrics  -> Prometheus -> Grafana
Logs     -> Fluent Bit -> OpenSearch -> OpenSearch Dashboards
```

## Grafana dashboards

Grafana is for metrics, health, capacity, and alert visibility.

### 1. EKS cluster overview

Purpose: Show whether the cluster is healthy enough to run the application.

Panels:

- Cluster CPU usage
- Cluster memory usage
- Node count
- Pod count
- Running pods vs failed/pending pods
- Namespace resource usage
- Node readiness
- Kubernetes API server health

Portfolio screenshots:

- Full cluster overview dashboard
- Node readiness panel
- Pod status panel

### 2. Node resource dashboard

Purpose: Show worker node capacity and pressure.

Panels:

- CPU usage by node
- Memory usage by node
- Disk/filesystem usage by node
- Network receive/transmit by node
- Node load
- Node conditions

Portfolio screenshots:

- CPU and memory by node
- Disk usage by node

### 3. Namespace workload dashboard

Purpose: Show how each namespace behaves.

Namespaces:

- church-prod
- monitoring
- logging
- argocd
- kube-system

Panels:

- CPU by namespace
- Memory by namespace
- Pod count by namespace
- Container restarts by namespace
- Pending pods by namespace
- Failed pods by namespace

Portfolio screenshots:

- Namespace resource usage
- Restart count by namespace

### 4. Application service dashboard

Purpose: Show health of the church application microservices.

Services:

- frontend
- auth-service
- church-core-service
- document-service

Panels:

- Replicas desired vs available
- Pod restart count
- CPU per service
- Memory per service
- HTTP request rate, after app `/metrics` endpoints are added
- HTTP 4xx/5xx error rate, after app `/metrics` endpoints are added
- Request duration p95/p99, after app `/metrics` endpoints are added

Portfolio screenshots:

- Service pod health
- Service CPU/memory
- HTTP request rate after metrics endpoints exist

### 5. Ingress and ALB dashboard

Purpose: Show public traffic flow into the cluster.

Panels:

- Ingress request rate
- Ingress response codes
- ALB target health, if AWS metrics are integrated
- TLS/HTTPS status, if exposed through controller metrics
- WAF blocked requests, if CloudWatch or exporter integration is added

Portfolio screenshots:

- Ingress resource health
- HTTP status code trend

### 6. Storage dashboard

Purpose: Show persistent storage health.

Panels:

- PVC status
- PVC capacity
- PVC usage, where available
- Prometheus PVC
- Grafana PVC
- Alertmanager PVC
- OpenSearch PVC

Portfolio screenshots:

- PVCs bound
- Storage capacity by namespace

### 7. Backup dashboard

Purpose: Show Velero backup health.

Panels:

- Velero backup success/failure count
- Last backup status
- Backup duration
- Backup location availability
- Restore count

Portfolio screenshots:

- Velero backup status
- Last successful backup

## OpenSearch Dashboards

OpenSearch Dashboards is for searching logs, troubleshooting requests, and finding backend errors.

### Index pattern

Use this index pattern:

```text
kubernetes-*
```

### Important log fields

Expected fields from Fluent Bit and Kubernetes metadata:

```text
@timestamp
cluster
environment
kubernetes.namespace_name
kubernetes.pod_name
kubernetes.container_name
kubernetes.labels.app
kubernetes.host
app_log
log
stream
```

Expected fields from Pino JSON application logs:

```text
level
time
pid
hostname
reqId
req.method
req.url
req.host
res.statusCode
responseTime
msg
```

### 1. Application logs overview

Purpose: Show log volume and application activity.

Visualizations:

- Log count over time
- Log count by namespace
- Log count by service/container
- Top messages
- Recent logs table

Filters:

```text
kubernetes.namespace_name: church-prod
```

Portfolio screenshots:

- Log volume over time
- Recent application logs table

### 2. Error and exception dashboard

Purpose: Find backend failures quickly.

Visualizations:

- Error logs over time
- Error count by service
- Top error messages
- Recent error logs table
- 5xx responses by service, if logs contain statusCode

Filters:

```text
kubernetes.namespace_name: church-prod AND (level >= 50 OR res.statusCode >= 500 OR msg:*error*)
```

Portfolio screenshots:

- Error count by service
- Recent error logs

### 3. HTTP request dashboard

Purpose: Analyze backend request behavior from Pino logs.

Visualizations:

- Request count over time
- Requests by method
- Requests by URL
- Response status codes
- Average response time
- Slow requests table

Filters:

```text
kubernetes.namespace_name: church-prod AND req.method:*
```

Portfolio screenshots:

- Requests by endpoint
- Status code distribution
- Slow request table

### 4. Auth service dashboard

Purpose: Troubleshoot login, user, and auth-related activity.

Visualizations:

- Auth-service logs over time
- Login-related messages
- Failed auth responses
- 401/403 responses
- Recent auth-service logs

Filters:

```text
kubernetes.container_name: auth-service
```

Portfolio screenshots:

- Auth service logs
- Unauthorized response trend

### 5. Document service dashboard

Purpose: Troubleshoot upload, download, and document-service behavior.

Visualizations:

- Document-service logs over time
- Upload request logs
- Failed upload logs
- S3-related errors
- Slow document requests

Filters:

```text
kubernetes.container_name: document-service
```

Portfolio screenshots:

- Document upload logs
- Failed document request logs

### 6. Kubernetes system logs dashboard

Purpose: Troubleshoot cluster and addon components.

Visualizations:

- Logs by namespace
- Logs by kube-system component
- Fluent Bit errors
- OpenSearch errors
- AWS Load Balancer Controller logs
- ExternalDNS logs
- Velero logs

Filters:

```text
kubernetes.namespace_name: kube-system OR kubernetes.namespace_name: logging OR kubernetes.namespace_name: monitoring
```

Portfolio screenshots:

- Fluent Bit forwarding logs
- Controller logs

## Dashboard build order on apply day

1. Confirm Prometheus targets are healthy.
2. Import or use default Kubernetes Grafana dashboards from kube-prometheus-stack.
3. Create application service dashboard in Grafana.
4. Create Velero backup dashboard after Velero is running.
5. Confirm OpenSearch receives logs.
6. Create `kubernetes-*` index pattern in OpenSearch Dashboards.
7. Create Application Logs Overview dashboard.
8. Create Error and Exception dashboard.
9. Create HTTP Request dashboard.
10. Create Auth Service and Document Service dashboards.

## Metrics still needed from the application

The Kubernetes dashboards will work immediately after monitoring is deployed.

The application-specific HTTP dashboard requires each backend service to expose a Prometheus metrics endpoint:

```text
auth-service: /metrics
church-core-service: /metrics
document-service: /metrics
```

Recommended app metrics:

```text
http_requests_total
http_request_duration_seconds
http_request_errors_total
nodejs_eventloop_lag_seconds
process_cpu_seconds_total
process_resident_memory_bytes
database_connection_status
```

## Log improvements still needed from the application

The current Pino JSON logs are useful. For better dashboards, make sure logs include:

```text
service
environment
requestId
userId when safe
method
url
statusCode
responseTime
error message
error stack in non-sensitive form
```

Do not log passwords, tokens, session cookies, or sensitive member data.

## Apply-day screenshot list

Grafana:

- Cluster overview
- Node resource dashboard
- Namespace workload dashboard
- Application service dashboard
- PVC/storage dashboard
- Alertmanager alerts page

OpenSearch Dashboards:

- Index pattern created
- Application logs overview
- Error dashboard
- HTTP request dashboard
- Auth service logs
- Document service upload logs
