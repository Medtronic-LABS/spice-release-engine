variable "cluster_name" {
  description = "Cluster name used for resource naming and Kubernetes discovery tags"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (true for non-prod, false for prod)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}
