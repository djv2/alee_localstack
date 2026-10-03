resource "aws_iam_role_policy" "demo_overbroad" {
  name = "demo-overbroad-access"
  role = aws_iam_role.worker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
