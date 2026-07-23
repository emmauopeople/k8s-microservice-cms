# OpenSearch Dashboard Checklist

OpenSearch Dashboards is used for Kubernetes and application logs.

## Index pattern

Create this index pattern after Fluent Bit starts sending logs:

```text
kubernetes-*
```

Use `@timestamp` as the time field.

## Dashboards to create

1. Application Logs Overview
2. Error and Exception Dashboard
3. HTTP Request Dashboard
4. Auth Service Dashboard
5. Document Service Dashboard
6. Kubernetes System Logs Dashboard

## Important filters

Application logs:

```text
kubernetes.namespace_name: church-prod
```

Backend HTTP request logs:

```text
kubernetes.namespace_name: church-prod AND req.method:*
```

Errors:

```text
kubernetes.namespace_name: church-prod AND (level >= 50 OR res.statusCode >= 500 OR msg:*error*)
```

Auth service:

```text
kubernetes.container_name: auth-service
```

Document service:

```text
kubernetes.container_name: document-service
```

## Screenshot targets

- Index pattern created
- Logs arriving from church-prod namespace
- Error search/filter result
- HTTP request logs by endpoint
- Auth-service logs
- Document-service upload logs
- Fluent Bit logs showing successful forwarding
