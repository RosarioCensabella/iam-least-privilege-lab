output "analyzer_name" {
  description = "Name of the IAM Access Analyzer."
  value       = aws_accessanalyzer_analyzer.this.analyzer_name
}

output "analyzer_arn" {
  description = "ARN of the IAM Access Analyzer."
  value       = aws_accessanalyzer_analyzer.this.arn
}