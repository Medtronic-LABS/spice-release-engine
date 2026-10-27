output "cluster_name" {
  description = "EKS cluster name"
  value       = module.this.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.this.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster CA certificate (base64)"
  value       = module.this.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.this.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = module.this.cluster_oidc_issuer_url
}
