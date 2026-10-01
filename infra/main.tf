data "archive_file" "lambda" {
  type = "zip"
  source_file = "${path.module}/../app/handler.py"
  output_path = "${path.module}/lambda.zip"
}
resource "aws_s3_bucket" "uploads" {
  bucket = "localstack-demo-uploads"
  tags = { App = "localstack-demo", Environment = "demo" }
}
resource "aws_sqs_queue" "jobs" {
  name = "localstack-demo-jobs"
  tags = { App = "localstack-demo" }
}
resource "aws_iam_role" "worker" {
  name = "localstack-demo-worker"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy" "worker_queue" {
  name = "read-demo-queue"
  role = aws_iam_role.worker.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"], Resource = aws_sqs_queue.jobs.arn }] })
}
resource "aws_lambda_function" "worker" {
  function_name = "localstack-demo-worker"
  role = aws_iam_role.worker.arn
  handler = "handler.handler"
  runtime = "python3.11"
  filename = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout = 10
  tags = { App = "localstack-demo" }
}
