variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the EKS cluster into"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API endpoint"
  type        = bool
  default     = true
}

variable "bootstrap_instance_type" {
  description = "Instance type for the bootstrap managed node group"
  type        = string
  default     = "t3.medium"
}

variable "bootstrap_min_size" {
  description = "Minimum number of nodes in the bootstrap node group"
  type        = number
  default     = 1
}

variable "bootstrap_max_size" {
  description = "Maximum number of nodes in the bootstrap node group"
  type        = number
  default     = 3
}

variable "bootstrap_desired_size" {
  description = "Desired number of nodes in the bootstrap node group"
  type        = number
  default     = 1
}

variable "partition" {
  description = "AWS partition (e.g. aws, aws-cn, aws-us-gov)"
  type        = string
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
  description = "Tags to apply to all EKS resources"
  type        = map(string)
  default     = {}
}
