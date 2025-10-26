# S3 Bucket for backups and assets
resource "aws_s3_bucket" "erpnext_backup" {
  bucket_prefix = "${var.project_name}-backup-"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "erpnext_backup" {
  bucket = aws_s3_bucket.erpnext_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "erpnext_backup" {
  bucket = aws_s3_bucket.erpnext_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "erpnext_backup" {
  bucket = aws_s3_bucket.erpnext_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}