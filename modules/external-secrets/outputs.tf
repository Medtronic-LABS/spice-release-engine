output "iam_role_arn" {
  description = "IAM role ARN used by External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "namespace" {
  description = "Namespace where External Secrets Operator is installed"
  value       = var.namespace
}
