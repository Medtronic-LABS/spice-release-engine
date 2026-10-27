variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  type        = string
}

variable "partition" {
  description = "AWS partition (e.g. aws, aws-cn, aws-us-gov)"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region for IAM condition on RunInstances"
  type        = string
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "1.14.1"
}

variable "karpenter_replicas" {
  description = "Number of Karpenter controller replicas"
  type        = number
  default     = 2
}

variable "instance_types" {
  description = "Allowed EC2 instance types for Karpenter-provisioned nodes"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.xlarge", "m5.large", "m5.xlarge"]
}

variable "capacity_types" {
  description = "Allowed capacity types (on-demand, spot)"
  type        = list(string)
  default     = ["on-demand", "spot"]
}

variable "cpu_limit" {
  description = "Maximum total vCPUs Karpenter can provision"
  type        = string
  default     = "100"
}

variable "memory_limit" {
  description = "Maximum total memory Karpenter can provision"
  type        = string
  default     = "256Gi"
}

variable "project" {
  description = "Project name for SCP-compliant tagging"
  type        = string
}

variable "country" {
  description = "Country tag for SCP compliance"
  type        = string
}

variable "environment" {
  description = "Environment name for SCP-compliant tagging"
  type        = string
}

variable "owner" {
  description = "Owner tag for SCP compliance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
