variable "localstack_endpoint" {
  description = "Endpoint URL for the LocalStack instance. Defaults to local Docker for development."
  type        = string
  default     = "http://localhost:4566"
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
