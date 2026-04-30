output "role_name" {
  description = "Name of the IAM role for data analysts."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role for data analysts."
  value       = aws_iam_role.this.arn
}

output "policy_arn" {
  description = "ARN of the IAM policy attached to the data analyst role."
  value       = aws_iam_policy.this.arn
}