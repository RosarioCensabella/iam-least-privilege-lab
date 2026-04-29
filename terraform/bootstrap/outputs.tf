output "aws_account_id" {
  description = "AWS account ID where the Terraform state bucket was created."
  value       = data.aws_caller_identity.current.account_id
}

output "state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_region" {
  description = "AWS region where the Terraform state bucket was created."
  value       = var.aws_region
}

output "backend_hcl_example" {
  description = "Backend configuration example for terraform/envs/dev/backend.hcl."
  value = <<EOT
bucket       = "${aws_s3_bucket.terraform_state.bucket}"
key          = "iam-least-privilege-lab/dev/terraform.tfstate"
region       = "${var.aws_region}"
encrypt      = true
use_lockfile = true
EOT
}