locals {
  analyzer_name = "${var.project_name}-${var.environment}-access-analyzer"
}

resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = local.analyzer_name
  type          = var.analyzer_type

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Analyze external access and validate IAM least privilege posture"
  }
}