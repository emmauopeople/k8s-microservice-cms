# Application Deployment Alignment Plan

This document aligns the EKS deployment plan with the current `emmauopeople/church_app` application repository on the `feature` branch.

## Application services

| Service | Source path | Container port | ECR repository | Database |
|---|---|---:|---|---|
| frontend | `frontend` | 8080 | `church-frontend` | none |
| auth-service | `apps/auth-service` | 4001 | `church-auth-service` | `auth_db` |
| church-core-service | `apps/church-core-service` | 4002 | `church-core-service` | `church_core_db` |
| document-service | `apps/document-service` | 4003 | `church-document-core-service` | `document_core_db` |

## Health and metrics endpoints

Backend services expose:

```text
/health
/health/db
/metrics
```

The frontend exposes:

```text
/health
```

Prometheus ServiceMonitor resources should scrape only the backend services because they already expose `/metrics` through `prom-client`.

## Frontend API URL model

The frontend is a Vite build. API URLs are build-time variables:

```text
VITE_AUTH_API_URL
VITE_CHURCH_CORE_API_URL
VITE_DOCUMENT_API_URL
VITE_DEFAULT_LANGUAGE
```

For the EKS demo, all three API variables should point to the same API hostname:

```text
https://api.eks.gestionparoissiale.org
```

The frontend code appends service paths such as:

```text
/auth/login
/core/members
/documents/files
```

The ALB ingress therefore routes:

```text
api.eks.gestionparoissiale.org/auth      -> auth-service
api.eks.gestionparoissiale.org/core      -> church-core-service
api.eks.gestionparoissiale.org/documents -> document-service
```

The frontend host routes:

```text
eks.gestionparoissiale.org -> frontend
```

## Database secret plan

The application code reads database connection strings from the `DATABASE_URL` environment variable.

Kubernetes secrets needed:

```text
auth-service-db
  DATABASE_URL=postgresql://auth_db_user:<password>@<rds-endpoint>:5432/auth_db

church-core-service-db
  DATABASE_URL=postgresql://church_core_db_user:<password>@<rds-endpoint>:5432/church_core_db

document-service-db
  DATABASE_URL=postgresql://document_core_db_user:<password>@<rds-endpoint>:5432/document_core_db
```

JWT secrets needed:

```text
auth-service-secret
  JWT_SECRET=<shared-or-service-specific-secret>

church-core-service-secret
  JWT_SECRET=<same-secret-used-to-verify-auth-tokens>

document-service-secret
  JWT_SECRET=<same-secret-used-to-verify-auth-tokens>
```

The current Terraform RDS module creates the RDS instance and initial master secret. App-level database users still need a bootstrap step after RDS is available.

## Current document storage behavior

The current document-service stores uploaded document file content in PostgreSQL as `BYTEA` in the `church_documents.file_content` column.

The platform already has an S3 document bucket and IRSA role for future S3 document storage, but the application code still needs a later change before uploaded files move from PostgreSQL to S3.

For the first EKS demo, use the current database-backed document storage behavior to keep migration simple.

## CI/CD alignment

Current app workflow behavior:

```text
push to main -> build images -> push images to ECR
workflow_dispatch -> build images -> push images to ECR
```

Deployment to EKS should happen only after merge to `main`.

Required next CI/CD update:

1. Build and push the four images to ECR.
2. Capture `prod-<short-sha>` image tags.
3. Update `helm/apps/church-app/values.yaml` in the platform repo.
4. Commit the tag update to the platform repo main branch.
5. Let Argo CD sync the new image tags into EKS.

## Apply-day order

1. Terraform apply platform foundation.
2. Delegate `eks.gestionparoissiale.org` in Namecheap to Route 53.
3. Validate ACM.
4. Install/sync Argo CD.
5. Create application Kubernetes secrets.
6. Sync infrastructure add-ons.
7. Build and push app images from app repo main.
8. Update image tags in the platform repo.
9. Sync `church-app` Argo CD application.
10. Validate frontend, backend health endpoints, metrics, and logs.

## Known gaps before apply

- App workflow does not yet update platform repo image tags.
- Frontend workflow does not yet pass production Vite API URLs as Docker build args.
- App-level database users and passwords need a bootstrap plan.
- Document-service currently stores file bytes in PostgreSQL, not S3.
- No Kubernetes secret creation script yet.
