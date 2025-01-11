terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

resource "aws_lambda_function" "count_visitors" {
  function_name    = "count_visitors"
  role             = aws_iam_role.iam.arn
  handler          = "lambda_func.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.lamda_cloud_resume_func.output_path)
  filename         = data.archive_file.lamda_cloud_resume_func.output_path
  runtime          = "python3.9"
}

resource "aws_iam_role" "iam" {
  name = "count_visitors_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "dynamo_access" {
  name = "lambda_dynamo_access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:UpdateItem",
        "dynamodb:GetItem",
      ],
      Resource : "arn:aws:dynamodb:*:*:table/cloudResumeChallengevisitorCount"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachement" {
  role       = aws_iam_role.iam.name
  policy_arn = aws_iam_policy.dynamo_access.arn
}

resource "aws_lambda_function_url" "url" {
  authorization_type = "NONE"
  function_name      = aws_lambda_function.count_visitors.function_name

  cors {
    allow_credentials = true
    allow_origins     = ["https://2.cloudresumechallengebyfelix.click"]
    allow_methods     = ["*"]
    allow_headers     = ["keep-alive", "date"]
    expose_headers    = ["date", "keep-alive"]
    max_age           = 86400
  }
}

data "archive_file" "lamda_cloud_resume_func" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_func.py"
  output_path = "${path.module}/zip_lambda.zip"
}