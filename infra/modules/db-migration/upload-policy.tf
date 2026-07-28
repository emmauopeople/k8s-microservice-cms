data "aws_iam_policy_document" "backup_uploader" {
  statement {
    sid    = "ListMigrationBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.migration.arn]
  }

  statement {
    sid    = "UploadMigrationBackups"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.migration.arn}/*"]
  }

  statement {
    sid    = "EncryptMigrationBackups"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [aws_kms_key.migration.arn]
  }
}

resource "aws_iam_policy" "backup_uploader" {
  name        = "${var.name}-backup-uploader"
  description = "Temporary least-privilege policy for uploading OVH PostgreSQL backups to the migration bucket"
  policy      = data.aws_iam_policy_document.backup_uploader.json

  tags = local.common_tags
}
