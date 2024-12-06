output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.json_file_bucket.bucket
}

output "lambda_function_name" {
  description = "Name of the created Lambda function"
  value       = aws_lambda_function.json_handler.function_name
}