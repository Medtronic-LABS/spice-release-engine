output "ebs_csi_irsa_role_arn" {
  description = "IAM role ARN for the EBS CSI driver"
  value       = module.ebs_csi_irsa.iam_role_arn
}
