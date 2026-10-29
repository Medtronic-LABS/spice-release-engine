variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "storage_class" {
  description = "Default StorageClass for persistent volumes (Grafana, Loki)"
  type        = string
  default     = "gp3"
}

variable "prometheus_storage_class" {
  description = "StorageClass for Prometheus persistent volume (can be EFS for shared/durable storage)"
  type        = string
  default     = ""
}

# --- Prometheus ---

variable "prometheus_stack_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "68.4.5"
}

variable "prometheus_replicas" {
  description = "Number of Prometheus replicas"
  type        = number
  default     = 1
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Persistent volume size for Prometheus. Empty string disables persistence."
  type        = string
  default     = "50Gi"
}

variable "prometheus_resources" {
  description = "Resource requests/limits for Prometheus"
  type        = map(map(string))
  default = {
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
    limits = {
      memory = "2Gi"
    }
  }
}

# --- Grafana ---

variable "grafana_enabled" {
  description = "Enable Grafana deployment"
  type        = bool
  default     = true
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas"
  type        = number
  default     = 1
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "CHANGEME"
}

variable "grafana_storage_size" {
  description = "Persistent volume size for Grafana. Empty string disables persistence."
  type        = string
  default     = "10Gi"
}

variable "grafana_service_type" {
  description = "Service type for Grafana (ClusterIP, LoadBalancer, NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "grafana_ingress_enabled" {
  description = "Enable ingress for Grafana"
  type        = bool
  default     = false
}

variable "grafana_domain" {
  description = "Domain name for Grafana"
  type        = string
  default     = ""
}

variable "grafana_ingress_annotations" {
  description = "Annotations for Grafana ingress"
  type        = map(string)
  default     = {}
}

variable "grafana_ingress_group_name" {
  description = "ALB ingress group name for Grafana. All ingresses sharing the same group use the same ALB."
  type        = string
  default     = "spice-monitoring"
}

variable "grafana_certificate_arn" {
  description = "ACM certificate ARN for Grafana HTTPS ingress. Empty uses HTTP only."
  type        = string
  default     = ""
}

variable "ingress_class_name" {
  description = "Ingress class name"
  type        = string
  default     = "alb"
}

# --- Alertmanager ---

variable "alertmanager_enabled" {
  description = "Enable Alertmanager"
  type        = bool
  default     = true
}

variable "alertmanager_replicas" {
  description = "Number of Alertmanager replicas"
  type        = number
  default     = 1
}

# --- Loki ---

variable "loki_enabled" {
  description = "Enable Loki log aggregation"
  type        = bool
  default     = true
}

variable "loki_version" {
  description = "Loki Helm chart version"
  type        = string
  default     = "6.24.1"
}

variable "loki_storage_size" {
  description = "Persistent volume size for Loki. Empty string disables persistence."
  type        = string
  default     = "50Gi"
}

variable "promtail_version" {
  description = "Promtail Helm chart version"
  type        = string
  default     = "6.16.6"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
