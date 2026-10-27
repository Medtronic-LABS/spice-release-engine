variable "cluster_name" {
  description = "Name prefix for Aurora resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for security group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "16.8"
}

variable "database_name" {
  description = "Default database name"
  type        = string
  default     = "spice"
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "spiceadmin"
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "min_capacity" {
  description = "Minimum ACUs for serverless v2 (0.5 to 256)"
  type        = number
  default     = 0.5
}

variable "max_capacity" {
  description = "Maximum ACUs for serverless v2"
  type        = number
  default     = 4
}

variable "instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  description = "Days to retain backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
