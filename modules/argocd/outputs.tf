output "namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "helm_release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.this.name
}

output "helm_release_version" {
  description = "Version of the ArgoCD Helm chart"
  value       = helm_release.this.version
}
