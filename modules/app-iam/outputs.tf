output "irsa_role_arn" {
  description = "IAM role ARN for the application service account (IRSA)"
  value       = module.this.iam_role_arn
}

output "s3_policy_arn" {
  description = "S3 access policy ARN"
  value       = aws_iam_policy.s3.arn
}
