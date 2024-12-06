# choose provider
provider "aws" {
  region = "us-east-1"
}

#  stating that i want an S3 bucket to store the JSON file
resource "aws_s3_bucket" "json_file_bucket" {
  bucket = var.s3_bucket_name

  # ensure that bucket is private
  # acl    = "private"
  # it was depricated so i removed it, cause now by default it is private unless a bucket policy is added and explicitly allows public access

  tags = {
    # Tag to identify the bucket
    Name = "JSONFileBucket"
  }
}

# Add IAM roles and policies

# IAM role for the Lambda function
resource "aws_iam_role" "lambda_fn_role" {
  name = "lambda_fn_role"

  # Allow lambda to assume this role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF 
}

# IAM policy for the Lambda function to access the S3 bucket and CloudWatch
resource "aws_iam_policy" "lambda_fn_policy" {
  name        = "lambda_fn_policy"
  description = "IAM policy for the Lambda function to access the S3 bucket and CloudWatch"


  #  arn = amazon resource name, its like pointing to a specific resource
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Effect": "Allow",
    "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
    ],
    "Resource": [
        "${aws_s3_bucket.json_file_bucket.arn}",
        "${aws_s3_bucket.json_file_bucket.arn}/*"
    ]
    },
    {
    "Effect": "Allow",
    "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ],
    "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

# Attach the Lambda function policy to the Lambda function role
resource "aws_iam_role_policy_attachment" "lambda_fn_role_attachment" {
  role       = aws_iam_role.lambda_fn_role.name
  policy_arn = aws_iam_policy.lambda_fn_policy.arn
}

# Define the Lambda function now that the IAM role and policy are set up
resource "aws_lambda_function" "json_handler" {
  function_name = "json_handler"
  role          = aws_iam_role.lambda_fn_role.arn
  handler       = "lambda_function.handler" # Name of the lambda_function (for this one its name will be "handler", so in the lambda_function.js file it must be exported as handler, so exports.handler)
  runtime       = "nodejs16.x" # Lambda function runtime, used the latest version of nodejs that it supports
  filename      = "../lambda_function.zip"

  # Enviroment variables for the Lambda function
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.json_file_bucket.bucket
    }
  }
}

# Allow S3 to trigger / invoke the Lambda function
resource "aws_lambda_permission" "trigger_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.json_handler.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.json_file_bucket.arn
}

#  When S3 should trigger the Lambda function? On a file upload or change or copy trigger it
resource "aws_s3_bucket_notification" "s3_trigger_conditions" {
  bucket = aws_s3_bucket.json_file_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.json_handler.arn
    # Trigger conditions
    events = ["s3:ObjectCreated:*"]
  }
}