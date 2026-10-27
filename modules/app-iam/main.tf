module "this" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-app"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.app_namespace}:${var.service_account_name}"]
    }
  }

  role_policy_arns = {
    s3 = aws_iam_policy.s3.arn
  }

  tags = var.tags
}

resource "aws_iam_policy" "s3" {
  name        = "${var.cluster_name}-app-s3"
  description = "S3 access for ${var.project} application workloads"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:${var.partition}:s3:::${var.project}-${var.environment}-*",
          "arn:${var.partition}:s3:::${var.project}-${var.environment}-*/*",
        ]
      }
    ]
  })

  tags = var.tags
}
