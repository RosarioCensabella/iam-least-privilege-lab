output "aws_account_id" {
  description = "AWS account ID used by the dev environment."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  description = "AWS ARN used by Terraform in the dev environment."
  value       = data.aws_caller_identity.current.arn
}

output "aws_region" {
  description = "AWS region used by the dev environment."
  value       = data.aws_region.current.region
}

output "environment" {
  description = "Current Terraform environment."
  value       = var.environment
}

output "s3_data_bucket_name" {
  description = "Name of the S3 data bucket used for the IAM least privilege lab."
  value       = module.s3_data_bucket.bucket_name
}

output "s3_data_bucket_arn" {
  description = "ARN of the S3 data bucket used for the IAM least privilege lab."
  value       = module.s3_data_bucket.bucket_arn
}

output "data_analyst_role_name" {
  description = "Name of the IAM role used by data analysts."
  value       = module.iam_data_analyst_role.role_name
}

output "data_analyst_role_arn" {
  description = "ARN of the IAM role used by data analysts."
  value       = module.iam_data_analyst_role.role_arn
}

output "data_analyst_policy_arn" {
  description = "ARN of the IAM policy attached to the data analyst role."
  value       = module.iam_data_analyst_role.policy_arn
}

output "access_analyzer_name" {
  description = "Name of the IAM Access Analyzer."
  value       = module.iam_access_analyzer.analyzer_name
}

output "access_analyzer_arn" {
  description = "ARN of the IAM Access Analyzer."
  value       = module.iam_access_analyzer.analyzer_arn
}

output "s3_development_bucket_name" {
  description = "Name of the S3 development bucket."
  value       = module.s3_development_bucket.bucket_name
}

output "s3_development_bucket_arn" {
  description = "ARN of the S3 development bucket."
  value       = module.s3_development_bucket.bucket_arn
}

output "s3_production_bucket_name" {
  description = "Name of the S3 production bucket."
  value       = module.s3_production_bucket.bucket_name
}

output "s3_production_bucket_arn" {
  description = "ARN of the S3 production bucket."
  value       = module.s3_production_bucket.bucket_arn
}