terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
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
    iam    = var.localstack_endpoint
    sts    = var.localstack_endpoint
    logs   = var.localstack_endpoint
    events = var.localstack_endpoint
  }
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

