data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "s3_data_bucket" {
  source = "../../modules/s3_data_bucket"

  project_name = "novacloud-iam-lab"
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
}

module "s3_development_bucket" {
  source = "../../modules/s3_secure_bucket"

  bucket_name = "novacloud-iam-lab-${var.environment}-development-${data.aws_caller_identity.current.account_id}"

  project_name  = "novacloud-iam-lab"
  environment   = var.environment
  purpose       = "Development bucket for developer team read and write access"
  force_destroy = false

  folder_keys = [
    "uploads/",
    "logs/"
  ]
}

module "s3_production_bucket" {
  source = "../../modules/s3_secure_bucket"

  bucket_name = "novacloud-iam-lab-${var.environment}-production-${data.aws_caller_identity.current.account_id}"

  project_name  = "novacloud-iam-lab"
  environment   = var.environment
  purpose       = "Protected production bucket used for least privilege negative tests"
  force_destroy = false

  folder_keys = [
    "protected/"
  ]
}

module "iam_data_analyst_role" {
  source = "../../modules/iam_data_analyst_role"

  project_name          = "novacloud-iam-lab"
  environment           = var.environment
  bucket_arn            = module.s3_data_bucket.bucket_arn
  trusted_principal_arn = data.aws_caller_identity.current.arn
}

module "iam_access_analyzer" {
  source = "../../modules/iam_access_analyzer"

  project_name = "novacloud-iam-lab"
  environment  = var.environment
}