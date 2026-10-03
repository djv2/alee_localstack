resource "aws_iam_policy" "demo_wildcard" {
  name        = "demo-wildcard-policy"
  description = "Intentional demo finding: overly broad permissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
