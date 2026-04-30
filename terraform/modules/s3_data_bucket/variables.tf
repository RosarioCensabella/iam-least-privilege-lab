variable "project_name" {
  description = "Name of the project used for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "account_id" {
  description = "AWS account ID used to generate globally unique resource names."
  type        = string
}
