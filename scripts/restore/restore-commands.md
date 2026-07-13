# Restore Command Examples

Use these commands only after confirming the target environment and backup names.

## List Velero backups

```bash
velero backup get
```

## Describe a Velero backup

```bash
velero backup describe <backup-name>
```

## Restore Kubernetes resources from Velero

```bash
velero restore create restore-<backup-name> --from-backup <backup-name>
```

## Check restore status

```bash
velero restore get
velero restore describe restore-<backup-name>
```

## Restore RDS from a manual snapshot

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier church-prod-demo-postgres-restore \
  --db-snapshot-identifier <snapshot-id>
```

## List object versions in the S3 document bucket

```bash
aws s3api list-object-versions \
  --bucket <document-bucket-name> \
  --prefix <object-key>
```

## Restore an S3 object version

```bash
aws s3api copy-object \
  --bucket <document-bucket-name> \
  --copy-source '<document-bucket-name>/<object-key>?versionId=<version-id>' \
  --key '<object-key>'
```
