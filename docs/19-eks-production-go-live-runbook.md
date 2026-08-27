# Church Management System — EKS Production Go-Live Runbook

## Purpose

This runbook moves the Church Management System from the current Docker Swarm deployment to AWS EKS while keeping the existing Swarm application available until the EKS environment, migrated databases, TLS, ingress, monitoring, logging, and backups have been validated.

The intended transition is parallel-first, cutover-last:

```text
Current users -> existing Swarm deployment -> OVHcloud PostgreSQL

                         while EKS is prepared and tested

Administrators -> eks.gestionparoissiale.org -> AWS ALB -> EKS -> RDS PostgreSQL
```

The Swarm deployment must not be stopped merely because EKS infrastructure exists. Final write cutover occurs only after a planned database maintenance window.

## Current readiness status

Repository preparation completed on `eks-production-readiness`:

- AWS Load Balancer Controller GitOps application added.
- ExternalDNS GitOps application added.
- ALB health checks use `/health` and HTTP 200 success criteria.
- EKS Kubernetes version pinned to 1.36.
- RDS PostgreSQL pinned to 16.14 to match the PostgreSQL 16 source family.
- RDS deletion protection enabled by default.
- Final RDS snapshot required by default.
- RDS backup retention increased to 14 days.
- Initial RDS class changed to `db.t4g.small`.
- EKS public API no longer allows `0.0.0.0/0`; an administrator CIDR is required.
- Initial EKS node group sized at desired 3, minimum 2, maximum 5 `t3.medium` workers.
- EBS CSI and encrypted gp3 StorageClass available for persistent Kubernetes workloads.
- S3 -> private EC2 -> private RDS migration architecture added.
- Database backup paths are ignored by Git.
- RDS application roles aligned to `auth_db_user`, `church_db_user`, and `document_db_user`.
- Argo CD bootstrap pinned to v3.5.1.
- Helm AWS metadata overlay added.
- Terraform/Helm/Shell CI validation added and passing.

No Terraform apply has been performed as part of repository preparation.

---

# 26-Step Go-Live Execution

## Step 1 — Preserve the current Swarm deployment

Do not change the existing production DNS or stop the Swarm services.

Record before beginning:

- Current production URL(s).
- Current Swarm service state.
- Current OVH PostgreSQL endpoint(s).
- Current database names.
- Current database application roles.
- Current container image versions.

This gives a known rollback target throughout the EKS build.

## Step 2 — Merge the EKS readiness branch only after CI is green

Required checks:

```text
Terraform format and validate     PASS
Helm lint and render              PASS
ShellCheck                        PASS
```

Do not merge any historical database dump files or backup archives into `main`.

## Step 3 — Remove historical database backups from Git history

The visible backup files were removed from the old feature branch, but Git history may still contain the original objects.

Before final public release of the repository:

1. Keep secured offline copies of the required database backups.
2. Rewrite Git history to remove `db_backups/` and `backups.zip`.
3. Force-push the cleaned repository history during a controlled maintenance operation for the Git repository.
4. Re-clone afterward to verify the files are gone.
5. Rotate any database credentials that may have been present in exposed backup content or related configuration.

This operation is destructive to Git history and must be performed separately from application deployment.

## Step 4 — Prepare local Terraform configuration

Copy:

```bash
cd infra/envs/prod-demo
cp terraform.tfvars.example terraform.tfvars
```

Replace the documentation CIDR with the current administrator public IPv4 address:

```hcl
eks_public_access_cidrs = ["<ADMIN_PUBLIC_IPV4>/32"]
```

Review:

```hcl
eks_kubernetes_version = "1.36"
rds_engine_version      = "16.14"
rds_instance_class      = "db.t4g.small"
rds_multi_az            = false
```

`rds_multi_az = false` and a single NAT Gateway are initial cost-control decisions, not the highest-availability configuration. Revisit them before the environment becomes business-critical.

## Step 5 — Run pre-apply validation locally

From `infra/envs/prod-demo`:

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan -out=tfplan
terraform show tfplan
```

The plan must be reviewed before apply.

Do not apply if the plan unexpectedly destroys or replaces existing resources.

## Step 6 — First Terraform apply

The first apply creates the AWS foundation while ACM validation remains disabled:

```bash
terraform apply tfplan
```

Expected major resources include:

- VPC.
- Public application ingress subnets.
- Private EKS application subnets.
- Private database subnets.
- NAT Gateway.
- ECR repositories.
- EKS control plane.
- EKS managed node group.
- EBS CSI addon.
- Private RDS PostgreSQL.
- S3 document bucket.
- Route 53 hosted zone.
- ACM certificate request.
- WAF Web ACL.
- IRSA roles.
- Velero S3 bucket and IAM role.

At this point the existing Swarm deployment remains production.

## Step 7 — Capture Terraform outputs

Record at minimum:

```bash
terraform output dns_name_servers
terraform output rds_endpoint
terraform output acm_certificate_arn
terraform output waf_web_acl_arn
terraform output irsa_aws_load_balancer_controller_role_arn
terraform output irsa_external_dns_role_arn
terraform output irsa_ebs_csi_role_arn
terraform output irsa_document_service_s3_role_arn
terraform output velero_backup_bucket_name
```

Store the deployment record securely. ARNs and endpoints are not passwords, but database credentials must never be placed in Git.

## Step 8 — Delegate the EKS subdomain to Route 53

Delegate only:

```text
eks.gestionparoissiale.org
```

from the current DNS provider to the Route 53 name servers returned by Terraform.

Do not move the current production root domain during this step.

This allows the EKS environment to be tested independently while Swarm remains live.

## Step 9 — Enable ACM DNS validation

After delegation resolves correctly, set:

```hcl
enable_acm_certificate_validation = true
```

Then:

```bash
terraform plan -out=tfplan-acm
terraform apply tfplan-acm
```

Confirm the certificate becomes `ISSUED` before deploying the public ALB ingress.

## Step 10 — Configure kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name church-prod-demo-eks

kubectl get nodes -o wide
```

Expected result: the managed nodes are `Ready`.

## Step 11 — Bootstrap pinned Argo CD

Run:

```bash
scripts/eks/bootstrap-argocd.sh
```

The script installs pinned Argo CD v3.5.1 and waits for critical deployments.

Confirm:

```bash
kubectl -n argocd get pods
```

## Step 12 — Create operational secrets that GitOps does not store

At minimum create the Grafana admin secret before the monitoring application syncs:

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic grafana-admin-credentials \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<GENERATED_STRONG_PASSWORD>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Never commit the password.

## Step 13 — Render AWS-specific Helm metadata

After ACM, WAF, and IRSA exist:

```bash
scripts/eks/render-aws-generated-values.sh
```

Review:

```text
helm/apps/church-app/values-aws-generated.yaml
```

It should contain:

- ACM certificate ARN.
- WAF ARN.
- document-service IRSA role ARN.

These are non-secret deployment identifiers and can be committed after review.

## Step 14 — Bootstrap platform GitOps applications

Run:

```bash
scripts/eks/apply-gitops-apps.sh
```

The script submits applications in this order:

1. `storageclass-gp3`
2. `aws-load-balancer-controller`
3. `external-dns`
4. `monitoring`
5. `opensearch`
6. `opensearch-dashboards`
7. `fluent-bit`
8. `velero`

Wait until the foundational components are healthy before deploying `church-app`.

## Step 15 — Validate platform services before application migration

Check:

```bash
kubectl -n argocd get applications
kubectl -n kube-system get pods
kubectl -n external-dns get pods
kubectl -n monitoring get pods,pvc
kubectl -n logging get pods,pvc
kubectl -n velero get pods
kubectl get storageclass
```

Do not proceed to the final database migration while core platform services are failing.

---

# Database Migration Phase

## Step 16 — Perform a rehearsal database backup while Swarm remains live

The rehearsal proves tooling and restore compatibility. It is not the final cutover backup because users can continue writing to OVH after it is created.

Preferred backup format:

```text
PostgreSQL custom format
--no-owner
--no-acl
```

Expected databases:

```text
auth_db
church_core_db
document_core_db
```

Expected application roles on RDS:

```text
auth_db_user
church_db_user
document_db_user
```

Use the backup tooling documented in `docs/18-s3-ec2-rds-migration-architecture.md`.

## Step 17 — Enable migration S3 storage and temporary EC2 host

In non-committed Terraform variables enable:

```hcl
enable_db_migration_storage = true
enable_db_migration_host    = true
```

Plan and apply only after reviewing the migration resources.

The migration EC2 host is designed with:

- Private subnet placement.
- No public IP.
- No SSH ingress.
- Systems Manager Session Manager access.
- Read-only access to the migration S3 bucket.
- PostgreSQL access to RDS on TCP 5432.
- Encrypted root volume.

## Step 18 — Upload backup set from secured workstation to migration S3

Use:

```bash
export MIGRATION_BUCKET='<terraform-output>'
export SOURCE_DIR='<secured-local-backup-directory>'
export BACKUP_FILES='auth_db.dump church_core_db.dump document_core_db.dump'

scripts/migration/upload-db-backups-to-s3.sh
```

The script creates checksums and a manifest before upload.

S3 is the secure staging layer. S3 does not perform the PostgreSQL restore itself.

## Step 19 — Download and verify backup on private EC2

Connect through Systems Manager Session Manager, then download the selected migration prefix.

On EC2:

```bash
export MIGRATION_BUCKET='<migration-bucket>'
export MIGRATION_PREFIX='<backup-prefix>'

scripts/migration/download-db-backups-from-s3.sh
```

Do not restore unless all SHA-256 checksums pass.

## Step 20 — Rehearsal restore to RDS and validate

Create RDS databases/application roles using:

```bash
scripts/rds/bootstrap-rds-app-databases.sh
```

Restore custom-format dumps using:

```bash
scripts/restore/restore-postgres-databases-to-rds.sh
```

Validate source versus target:

- Database list.
- Table list.
- Row count per table.
- Sequence values.
- PostgreSQL extensions.
- Representative users.
- Representative members.
- Sacrament records.
- Templates.
- Uploaded document counts and file sizes.

A successful rehearsal proves the restore process, but the data is not yet final because Swarm is still accepting writes.

---

# Final Cutover Phase

## Step 21 — Schedule a short write-freeze/maintenance window

A final consistent database backup requires stopping new writes to OVH.

Because the application currently runs on Swarm and does not use continuous PostgreSQL replication to RDS, the safest first migration is a controlled maintenance window.

Immediately before the final backup:

1. Confirm EKS platform is healthy.
2. Confirm RDS rehearsal restore succeeded.
3. Inform users of the maintenance window.
4. Stop or otherwise block write-capable Swarm backend services.
5. Verify no new database writes are occurring.

Do not destroy Swarm.

## Step 22 — Create and restore the final OVH backup

After writes are frozen:

1. Create fresh dumps from all three OVH databases.
2. Generate checksums.
3. Upload to the encrypted migration S3 bucket.
4. Download to the private migration EC2 host.
5. Verify checksums.
6. Clean/recreate or otherwise reset the RDS target databases as approved.
7. Restore the final dumps.
8. Re-run row-count and representative-record validation.

This final backup, not the rehearsal backup, becomes the EKS starting dataset.

## Step 23 — Create EKS database and JWT secrets

After the final RDS restore:

```bash
scripts/eks/create-church-app-secrets-from-rds.sh
```

The resulting application database URLs use:

```text
auth_db        -> auth_db_user
church_core_db -> church_db_user
document_core_db -> document_db_user
```

The secret values remain only in Kubernetes/AWS administrative handling, not Git.

## Step 24 — Deploy church-app through Argo CD and validate privately

Apply:

```bash
kubectl apply -f gitops/apps/church-app.yaml
```

Wait for:

```bash
kubectl -n argocd get application church-app -o wide
kubectl -n church-prod get deploy,pods,svc,ingress

kubectl -n church-prod rollout status deploy/frontend
kubectl -n church-prod rollout status deploy/auth-service
kubectl -n church-prod rollout status deploy/church-core-service
kubectl -n church-prod rollout status deploy/document-service
```

Check:

```text
https://eks.gestionparoissiale.org
https://api.eks.gestionparoissiale.org/auth/health
https://api.eks.gestionparoissiale.org/core/health
https://api.eks.gestionparoissiale.org/documents/health
```

Test real workflows before changing the current production URL:

- Login.
- Member lookup.
- Member creation/update if appropriate in the maintenance test window.
- Sacrament retrieval.
- Certificate/document generation.
- Uploaded document retrieval.

## Step 25 — Validate observability and backup before public cutover

Monitoring:

- Prometheus application targets are UP.
- Grafana receives request, latency, CPU, memory, and restart metrics.

Logging:

- Fluent Bit is running on nodes.
- OpenSearch receives `kubernetes-*` indices.
- Church application logs can be filtered by namespace and container.

Backups:

- RDS automated backup policy is active.
- Take a manual RDS post-migration snapshot.
- Velero is installed and can create an EKS backup.

Important separation:

```text
RDS backups/snapshots protect PostgreSQL data.
Velero protects Kubernetes resources and configured Kubernetes volume data.
S3 migration backup protects the temporary migration source artifacts.
```

Velero is not a replacement for RDS backups.

## Step 26 — Cut production traffic and retain rollback capability

Only after all validation passes:

1. Change the intended public production DNS to the validated EKS/ALB destination, or formally promote the EKS hostname according to the selected domain strategy.
2. Reduce DNS TTL in advance if a fast switch is required.
3. Confirm TLS and WAF behavior.
4. Confirm browser/API traffic reaches EKS.
5. Monitor error rate, latency, pod health, database health, and logs closely.
6. Keep the Swarm environment intact but write-disabled for the agreed rollback window.
7. Do not allow both Swarm and EKS to accept independent writes to separate databases after cutover.
8. When the rollback window closes, decommission Swarm deliberately.
9. Destroy the temporary migration EC2 host.
10. Retain the encrypted S3 migration backup only for the approved retention period.

---

# Rollback Strategy

Before public cutover, rollback is simple: continue using Swarm.

After public cutover but before Swarm decommissioning:

- If EKS fails before meaningful new writes occur, DNS can be returned to Swarm.
- If EKS has accepted new production writes, database state must be evaluated before rollback. Do not point users back to an older OVH database and silently discard RDS writes.

For this reason the safest rollback window either:

- keeps EKS validation short before live writes begin, or
- includes a deliberate data reconciliation plan if rollback becomes necessary after writes.

# Post-Go-Live Tasks

After stable production operation:

- Review actual EKS resource utilization and tune node sizes.
- Decide whether to enable Multi-AZ RDS.
- Decide whether to replace the single NAT Gateway with one per AZ.
- Add HPA/Karpenter or Cluster Autoscaler if traffic warrants it.
- Harden OpenSearch authentication/network isolation further.
- Add Alertmanager notification routing.
- Move document file bytes from PostgreSQL to the prepared S3 document-storage architecture when the application feature is implemented.
- Test RDS restore from snapshot.
- Test Velero restore into a non-production namespace/cluster.
- Document recovery time objective (RTO) and recovery point objective (RPO).
