output "namespace" {
  description = "Namespace where the monitoring stack is installed"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "prometheus_helm_release" {
  description = "Name of the Prometheus Helm release"
  value       = helm_release.prometheus.name
}

output "grafana_helm_release" {
  description = "Name of the Grafana Helm release (deployed within kube-prometheus-stack)"
  value       = helm_release.prometheus.name
}

output "loki_helm_release" {
  description = "Name of the Loki Helm release"
  value       = var.loki_enabled ? helm_release.loki[0].name : null
}
