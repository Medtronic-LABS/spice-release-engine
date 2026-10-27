output "file_system_id" {
  description = "EFS filesystem ID"
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "EFS filesystem ARN"
  value       = aws_efs_file_system.this.arn
}

output "storage_class_name" {
  description = "Name of the EFS StorageClass"
  value       = kubernetes_storage_class.efs.metadata[0].name
}

output "efs_csi_role_arn" {
  description = "IAM role ARN for the EFS CSI driver"
  value       = module.efs_csi_irsa.iam_role_arn
}

output "security_group_id" {
  description = "Security group ID for EFS mount targets"
  value       = aws_security_group.efs.id
}
