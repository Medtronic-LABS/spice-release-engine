output "node_iam_role_arn" {
  description = "IAM role ARN for Karpenter-provisioned nodes"
  value       = module.this.node_iam_role_arn
}

output "queue_name" {
  description = "SQS queue name for Karpenter interruption handling"
  value       = module.this.queue_name
}

output "iam_role_name" {
  description = "IAM role name for the Karpenter controller"
  value       = module.this.iam_role_name
}
