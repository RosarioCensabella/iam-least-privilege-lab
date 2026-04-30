variable "project_name" {
  description = "Name of the project used for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket that contains analytics reports."
  type        = string
}

variable "trusted_principal_arns" {
  description = "ARNs of the principals allowed to assume the data analyst role."
  type        = list(string)
}