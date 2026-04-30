variable "project_name" {
  description = "Name of the project used for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "analyzer_type" {
  description = "Type of IAM Access Analyzer."
  type        = string
  default     = "ACCOUNT"
}