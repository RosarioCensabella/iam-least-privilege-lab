variable "project_name" {
  description = "Name of the project used for tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group."
  type        = string
}

variable "retention_in_days" {
  description = "CloudWatch Logs retention period in days."
  type        = number
  default     = 7
}

variable "aws_region" {
  description = "AWS region used to build IAM resource ARNs for CloudWatch Logs."
  type        = string
}

variable "account_id" {
  description = "AWS account ID used to build IAM resource ARNs for CloudWatch Logs."
  type        = string
}