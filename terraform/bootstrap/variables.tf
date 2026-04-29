variable "aws_profile" {
  description = "AWS CLI named profile used by Terraform."
  type        = string
  default     = "iam-lab"
}

variable "aws_region" {
  description = "AWS region where the Terraform state bucket will be created."
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
  default     = "bootstrap"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name used to store Terraform remote state."
  type        = string
}

variable "state_bucket_force_destroy" {
  description = "Allow Terraform to delete the state bucket even if it contains objects. Keep false unless intentionally destroying the lab."
  type        = bool
  default     = false
}