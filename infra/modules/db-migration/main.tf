data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = var.ami_ssm_parameter
}

locals {
  common_tags = merge(var.tags, { Module = "db-migration" })
  bucket_name = lower("${var.name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}")
}

resource "aws_kms_key" "migration" {
  description             = "KMS key for church database migration backups and EC2 storage"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-kms"
  })
}

resource "aws_kms_alias" "migration" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.migration.key_id
}

resource "aws_s3_bucket" "migration" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name        = local.bucket_name
    DataClass   = "confidential"
    Purpose     = "ovh-to-rds-migration"
    Temporary   = "true"
  })
}

resource "aws_s3_bucket_ownership_controls" "migration" {
  bucket = aws_s3_bucket.migration.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "migration" {
  bucket = aws_s3_bucket.migration.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "migration" {
  bucket = aws_s3_bucket.migration.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "migration" {
  bucket = aws_s3_bucket.migration.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.migration.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "migration" {
  bucket = aws_s3_bucket.migration.id

  rule {
    id     = "expire-migration-backups"
    status = "Enabled"

    filter {}

    expiration {
      days = var.backup_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.migration]
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.migration.arn,
      "${aws_s3_bucket.migration.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "migration" {
  bucket = aws_s3_bucket.migration.id
  policy = data.aws_iam_policy_document.bucket.json

  depends_on = [aws_s3_bucket_public_access_block.migration]
}

resource "aws_iam_role" "instance" {
  count = var.create_instance ? 1 : 0

  name = "${var.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_instance ? 1 : 0

  role       = aws_iam_role.instance[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "instance_migration_access" {
  statement {
    sid       = "ListMigrationBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.migration.arn]
  }

  statement {
    sid       = "ReadMigrationBackups"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.migration.arn}/*"]
  }

  statement {
    sid       = "DecryptMigrationBackups"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [aws_kms_key.migration.arn]
  }
}

resource "aws_iam_role_policy" "instance_migration_access" {
  count = var.create_instance ? 1 : 0

  name   = "${var.name}-s3-read"
  role   = aws_iam_role.instance[0].id
  policy = data.aws_iam_policy_document.instance_migration_access.json
}

resource "aws_iam_instance_profile" "instance" {
  count = var.create_instance ? 1 : 0

  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance[0].name
}

resource "aws_security_group" "instance" {
  count = var.create_instance ? 1 : 0

  name        = "${var.name}-ec2-sg"
  description = "Private migration host: no inbound access; managed through AWS Systems Manager"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-ec2-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "https" {
  count = var.create_instance ? 1 : 0

  security_group_id = aws_security_group.instance[0].id
  description       = "HTTPS for SSM, package repositories, and AWS APIs"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "dns_udp" {
  count = var.create_instance ? 1 : 0

  security_group_id = aws_security_group.instance[0].id
  description       = "DNS over UDP inside the VPC"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "dns_tcp" {
  count = var.create_instance ? 1 : 0

  security_group_id = aws_security_group.instance[0].id
  description       = "DNS over TCP inside the VPC"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "postgres" {
  count = var.create_instance ? 1 : 0

  security_group_id            = aws_security_group.instance[0].id
  description                  = "PostgreSQL to the private RDS security group"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = var.rds_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_migration_host" {
  count = var.create_instance ? 1 : 0

  security_group_id            = var.rds_security_group_id
  description                  = "PostgreSQL from the temporary migration host"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.instance[0].id
}

data "aws_iam_policy_document" "s3_endpoint" {
  statement {
    sid    = "MigrationBucketOnly"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.migration.arn,
      "${aws_s3_bucket.migration.arn}/*"
    ]
  }
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_instance ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
  policy            = data.aws_iam_policy_document.s3_endpoint.json

  tags = merge(local.common_tags, {
    Name = "${var.name}-s3-endpoint"
  })
}

resource "aws_instance" "migration" {
  count = var.create_instance ? 1 : 0

  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.instance[0].id]
  iam_instance_profile        = aws_iam_instance_profile.instance[0].name
  associate_public_ip_address = false

  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail

    dnf install -y postgresql16 jq

    install -d -m 0700 -o ec2-user -g ec2-user /opt/church-db-migration

    cat > /etc/motd <<'MOTD'
    Church database migration host
    - Access through AWS Systems Manager Session Manager only
    - Backup working directory: /opt/church-db-migration
    - Do not store passwords or permanent credentials on this host
    MOTD
  USERDATA

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    kms_key_id            = aws_kms_key.migration.arn
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name      = "${var.name}-host"
    Temporary = "true"
    Access    = "ssm-only"
  })

  depends_on = [
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy.instance_migration_access,
    aws_vpc_endpoint.s3
  ]
}
