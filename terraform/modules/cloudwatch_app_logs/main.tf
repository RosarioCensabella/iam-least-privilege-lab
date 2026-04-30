resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Developer application log group for least privilege testing"
  }
}

resource "aws_cloudwatch_log_stream" "application" {
  name           = "application"
  log_group_name = aws_cloudwatch_log_group.this.name
}