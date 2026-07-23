module "s3_documents" {
  source = "../../modules/s3-documents"

  name          = "${local.name_prefix}-documents"
  force_destroy = var.document_bucket_force_destroy

  versioning_enabled = true

  cors_allowed_origins = var.document_bucket_cors_allowed_origins
  cors_allowed_methods = ["GET", "HEAD", "PUT", "POST"]

  noncurrent_version_expiration_days     = 30
  abort_incomplete_multipart_upload_days = 7

  tags = local.common_tags
}
