output "backend_bucket_output" {
  value = aws_s3_bucket.backend_bucket
}

output "backend_replication_target_bucket_output" {
  value = aws_s3_bucket.backend_replication_target_bucket
}