terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    archive = { source = "hashicorp/archive", version = "~> 2.4" }
  }
}

variable "localstack_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3     = var.localstack_endpoint
    sqs    = var.localstack_endpoint
    lambda = var.localstack_endpoint
    iam    = var.localstack_endpoint
    sts    = var.localstack_endpoint
    logs   = var.localstack_endpoint
    events = var.localstack_endpoint
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../app/handler.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket" "uploads" {
  bucket = "localstack-demo-uploads"
  tags   = { App = "localstack-demo", Environment = "demo" }
}

resource "aws_sqs_queue" "jobs" {
  name = "localstack-demo-jobs"
  tags = { App = "localstack-demo" }
}

resource "aws_iam_role" "worker" {
  name = "localstack-demo-worker"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "worker_queue" {
  name = "read-demo-queue"
  role = aws_iam_role.worker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = aws_sqs_queue.jobs.arn
    }]
  })
}

resource "aws_lambda_function" "worker" {
  function_name    = "localstack-demo-worker"
  role             = aws_iam_role.worker.arn
  handler          = "handler.handler"
  runtime          = "python3.11"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 10
  tags             = { App = "localstack-demo" }
}
