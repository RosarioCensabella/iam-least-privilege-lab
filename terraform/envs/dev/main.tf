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

  project_name = "novacloud-iam-lab"
  environment  = var.environment
  bucket_arn   = module.s3_data_bucket.bucket_arn

  trusted_principal_arns = [
    data.aws_caller_identity.current.arn,
    module.iam_users_groups.data_analyst_user_arn
  ]
}

module "iam_access_analyzer" {
  source = "../../modules/iam_access_analyzer"

  project_name = "novacloud-iam-lab"
  environment  = var.environment
}

module "cloudwatch_app_logs" {
  source = "../../modules/cloudwatch_app_logs"

  project_name      = "novacloud-iam-lab"
  environment       = var.environment
  log_group_name    = "/novacloud/iam-lab/${var.environment}/developer-app"
  retention_in_days = 7
  aws_region        = data.aws_region.current.region
  account_id        = data.aws_caller_identity.current.account_id
}

module "iam_least_privilege_policies" {
  source = "../../modules/iam_least_privilege_policies"

  project_name = "novacloud-iam-lab"
  environment  = var.environment

  developer_group_name         = module.iam_users_groups.developers_group_name
  data_analysts_group_name     = module.iam_users_groups.data_analysts_group_name
  security_auditors_group_name = module.iam_users_groups.security_auditors_group_name
  development_bucket_arn       = module.s3_development_bucket.bucket_arn
  data_analyst_role_arn        = module.iam_data_analyst_role.role_arn
  cloudwatch_log_group_arn     = module.cloudwatch_app_logs.log_group_arn_for_iam
  cloudwatch_log_streams_arn   = module.cloudwatch_app_logs.log_streams_arn_for_iam
}

module "iam_users_groups" {
  source = "../../modules/iam_users_groups"

  project_name = "novacloud-iam-lab"
  environment  = var.environment
}