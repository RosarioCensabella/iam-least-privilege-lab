variable "project_name" {
  description = "Name of the project used for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "developer_group_name" {
  description = "Name of the IAM developers group."
  type        = string
}

variable "data_analysts_group_name" {
  description = "Name of the IAM data analysts group."
  type        = string
}

variable "security_auditors_group_name" {
  description = "Name of the IAM security auditors group."
  type        = string
}

variable "development_bucket_arn" {
  description = "ARN of the S3 development bucket."
  type        = string
}

variable "data_analyst_role_arn" {
  description = "ARN of the MFA-protected data analyst read-only role."
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN for developer read-only log access."
  type        = string
}

variable "cloudwatch_log_streams_arn" {
  description = "CloudWatch log stream ARN pattern for developer read-only log access."
  type        = string
}