resource "aws_s3_bucket" "reports" {
  bucket = "localstack-demo-reports"
  tags = {
    App         = "localstack-demo"
    Environment = "demo"
    Owner       = "platform"
  }
}
