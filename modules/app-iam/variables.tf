variable "cluster_name" {
  description = "Cluster name for IRSA role naming"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "partition" {
  description = "AWS partition for ARN construction"
  type        = string
}

variable "project" {
  description = "Project name for S3 bucket pattern and naming"
  type        = string
}

variable "environment" {
  description = "Environment name for S3 bucket pattern"
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace for IRSA binding"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name for IRSA binding"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
