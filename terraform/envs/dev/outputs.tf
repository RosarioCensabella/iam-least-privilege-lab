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

output "developer_user_name" {
  description = "Name of the developer IAM user."
  value       = module.iam_users_groups.developer_user_name
}

output "developer_user_arn" {
  description = "ARN of the developer IAM user."
  value       = module.iam_users_groups.developer_user_arn
}

output "data_analyst_user_name" {
  description = "Name of the data analyst IAM user."
  value       = module.iam_users_groups.data_analyst_user_name
}

output "data_analyst_user_arn" {
  description = "ARN of the data analyst IAM user."
  value       = module.iam_users_groups.data_analyst_user_arn
}

output "security_auditor_user_name" {
  description = "Name of the security auditor IAM user."
  value       = module.iam_users_groups.security_auditor_user_name
}

output "security_auditor_user_arn" {
  description = "ARN of the security auditor IAM user."
  value       = module.iam_users_groups.security_auditor_user_arn
}

output "developers_group_name" {
  description = "Name of the developers IAM group."
  value       = module.iam_users_groups.developers_group_name
}

output "data_analysts_group_name" {
  description = "Name of the data analysts IAM group."
  value       = module.iam_users_groups.data_analysts_group_name
}

output "security_auditors_group_name" {
  description = "Name of the security auditors IAM group."
  value       = module.iam_users_groups.security_auditors_group_name
}

output "developer_policy_arn" {
  description = "ARN of the developer least privilege policy."
  value       = module.iam_least_privilege_policies.developer_policy_arn
}

output "data_analyst_assume_role_policy_arn" {
  description = "ARN of the data analyst assume role policy."
  value       = module.iam_least_privilege_policies.data_analyst_assume_role_policy_arn
}

output "security_auditor_policy_arn" {
  description = "ARN of the security auditor read-only policy."
  value       = module.iam_least_privilege_policies.security_auditor_policy_arn
}

output "developer_log_group_name" {
  description = "Name of the CloudWatch log group used for developer read-only log access."
  value       = module.cloudwatch_app_logs.log_group_name
}

output "developer_log_stream_name" {
  description = "Name of the CloudWatch log stream used for developer read-only log access."
  value       = module.cloudwatch_app_logs.log_stream_name
}