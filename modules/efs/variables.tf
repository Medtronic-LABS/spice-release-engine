variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for NFS security group rule"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EFS mount targets (typically private subnets)"
  type        = list(string)
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EFS CSI addon version lookup"
  type        = string
}

variable "throughput_mode" {
  description = "EFS throughput mode (bursting or elastic)"
  type        = string
  default     = "elastic"
}

variable "transition_to_ia" {
  description = "Transition files to Infrequent Access after this period"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "create_storage_class" {
  description = "Create the EFS StorageClass (disable for private clusters where K8s API is unreachable from Terraform)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
