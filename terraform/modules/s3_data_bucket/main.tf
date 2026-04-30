locals {
  bucket_name = lower("${var.project_name}-${var.environment}-${var.account_id}")
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "IAM least privilege lab data bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "reports_folder" {
  bucket  = aws_s3_bucket.this.id
  key     = "reports/"
  content = ""
}

resource "aws_s3_object" "evidence_folder" {
  bucket  = aws_s3_bucket.this.id
  key     = "evidence/"
  content = ""
}

