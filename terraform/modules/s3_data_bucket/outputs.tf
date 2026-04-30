output "bucket_name" {
  description = "Name of the S3 data bucket."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 data bucket."
  value       = aws_s3_bucket.this.arn
}
