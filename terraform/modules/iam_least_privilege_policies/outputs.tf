output "developer_policy_arn" {
  description = "ARN of the developer least privilege policy."
  value       = aws_iam_policy.developer.arn
}

output "data_analyst_assume_role_policy_arn" {
  description = "ARN of the data analyst assume role policy."
  value       = aws_iam_policy.data_analyst_assume_role.arn
}

output "security_auditor_policy_arn" {
  description = "ARN of the security auditor read-only policy."
  value       = aws_iam_policy.security_auditor.arn
}