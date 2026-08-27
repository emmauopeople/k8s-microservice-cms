locals {
  common_tags = merge(var.tags, { Module = "rds-postgres" })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.name}-subnet-group"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Allow PostgreSQL access from private application subnets"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from private application subnets"
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_name  = var.initial_database_name
  username = var.master_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false

  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : var.final_snapshot_identifier
  apply_immediately          = var.apply_immediately

  performance_insights_enabled = var.performance_insights_enabled

  lifecycle {
    precondition {
      condition     = var.skip_final_snapshot || (var.final_snapshot_identifier != null && length(trimspace(var.final_snapshot_identifier)) > 0)
      error_message = "final_snapshot_identifier must be set when skip_final_snapshot is false."
    }
  }

  tags = merge(local.common_tags, {
    Name = var.name
  })
}
