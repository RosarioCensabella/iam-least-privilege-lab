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