data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "s3_data_bucket" {
  source = "../../modules/s3_data_bucket"

  project_name = "novacloud-iam-lab"
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
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