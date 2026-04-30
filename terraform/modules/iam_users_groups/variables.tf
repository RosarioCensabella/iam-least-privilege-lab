variable "project_name" {
  description = "Name of the project used for IAM resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "iam_path" {
  description = "IAM path used for lab users and groups."
  type        = string
  default     = "/"
}