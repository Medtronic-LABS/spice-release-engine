variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.16"
}

variable "argocd_domain" {
  description = "Domain name for ArgoCD server"
  type        = string
  default     = ""
}

variable "server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 1
}

variable "controller_replicas" {
  description = "Number of ArgoCD application controller replicas"
  type        = number
  default     = 1
}

variable "repo_server_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "appset_replicas" {
  description = "Number of ArgoCD ApplicationSet controller replicas"
  type        = number
  default     = 1
}

variable "service_type" {
  description = "Service type for ArgoCD server (ClusterIP, LoadBalancer, NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "ingress_enabled" {
  description = "Enable ingress for ArgoCD server"
  type        = bool
  default     = false
}

variable "ingress_class_name" {
  description = "Ingress class name for ArgoCD"
  type        = string
  default     = "alb"
}

variable "ingress_annotations" {
  description = "Annotations for ArgoCD ingress"
  type        = map(string)
  default     = {}
}

variable "ingress_group_name" {
  description = "ALB ingress group name. All ingresses sharing the same group use the same ALB."
  type        = string
  default     = "spice-argocd"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for ArgoCD HTTPS ingress. Empty uses HTTP only."
  type        = string
  default     = ""
}

variable "server_insecure" {
  description = "Run ArgoCD server in insecure mode (no TLS). Required when TLS is terminated at the load balancer."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
