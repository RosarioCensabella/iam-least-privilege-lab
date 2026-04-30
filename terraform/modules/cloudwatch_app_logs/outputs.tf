output "log_group_name" {
  description = "Name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_stream_name" {
  description = "Name of the CloudWatch log stream."
  value       = aws_cloudwatch_log_stream.application.name
}

output "log_group_arn_for_iam" {
  description = "CloudWatch log group ARN used in IAM policies."
  value       = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.this.name}"
}

output "log_streams_arn_for_iam" {
  description = "CloudWatch log stream ARN pattern used in IAM policies."
  value       = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.this.name}:log-stream:*"
}