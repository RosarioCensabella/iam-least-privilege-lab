variable "bucket_name" {
  description = "Globally unique name of the S3 bucket."
  type        = string
}

variable "project_name" {
  description = "Name of the project used for tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, test, or prod."
  type        = string
}

variable "purpose" {
  description = "Purpose of the S3 bucket."
  type        = string
}

variable "folder_keys" {
  description = "Optional S3 prefix placeholder objects to create. Values should end with a slash."
  type        = list(string)
  default     = []
}

variable "force_destroy" {
  description = "Whether Terraform should delete all objects when destroying the bucket. Kept false by default for safer lab behavior."
  type        = bool
  default     = false
}