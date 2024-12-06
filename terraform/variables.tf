variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store the JSON file"
  # NAMING_RULES: NO Uppercase, no special characters (!_@etc) and no ending with a hyphen or dot
  default     = "zeronorth-challenge"
}
