variable "aws_profile" {
  description = "AWS CLI named profile used by Terraform."
  type        = string
  default     = "iam-lab"
}

variable "aws_region" {
  description = "AWS region where the IAM least privilege lab will be deployed."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used for tagging AWS resources."
  type        = string
  default     = "iam-least-privilege-lab"
}

variable "environment" {
  description = "Environment name used for tagging AWS resources."
  type        = string
  default     = "dev"
}