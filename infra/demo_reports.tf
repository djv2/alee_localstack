resource "aws_s3_bucket" "demo_reports" {
  bucket = "localstack-demo-reports"
  tags = {
    App         = "localstack-demo"
    Environment = "demo"
    Purpose     = "safe-change-example"
  }
}
