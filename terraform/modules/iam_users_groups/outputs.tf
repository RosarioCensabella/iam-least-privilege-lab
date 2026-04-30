output "developer_user_name" {
  description = "Name of the developer IAM user."
  value       = aws_iam_user.this["developer"].name
}

output "developer_user_arn" {
  description = "ARN of the developer IAM user."
  value       = aws_iam_user.this["developer"].arn
}

output "data_analyst_user_name" {
  description = "Name of the data analyst IAM user."
  value       = aws_iam_user.this["data_analyst"].name
}

output "data_analyst_user_arn" {
  description = "ARN of the data analyst IAM user."
  value       = aws_iam_user.this["data_analyst"].arn
}

output "security_auditor_user_name" {
  description = "Name of the security auditor IAM user."
  value       = aws_iam_user.this["security_auditor"].name
}

output "security_auditor_user_arn" {
  description = "ARN of the security auditor IAM user."
  value       = aws_iam_user.this["security_auditor"].arn
}

output "developers_group_name" {
  description = "Name of the developers IAM group."
  value       = aws_iam_group.this["developers"].name
}

output "data_analysts_group_name" {
  description = "Name of the data analysts IAM group."
  value       = aws_iam_group.this["data_analysts"].name
}

output "security_auditors_group_name" {
  description = "Name of the security auditors IAM group."
  value       = aws_iam_group.this["security_auditors"].name
}