variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "visibility_timeout" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30
}

variable "message_retention" {
  description = "Message retention period in seconds (default 4 days)"
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "Maximum message size in bytes (default 256KB)"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Delivery delay in seconds"
  type        = number
  default     = 0
}

variable "receive_wait_time" {
  description = "Long poll wait time in seconds"
  type        = number
  default     = 0
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (empty uses SQS managed SSE)"
  type        = string
  default     = ""
}

variable "create_dlq" {
  description = "Create a dead-letter queue"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Max receive count before sending to DLQ"
  type        = number
  default     = 3
}

variable "dlq_message_retention" {
  description = "DLQ message retention in seconds (default 14 days)"
  type        = number
  default     = 1209600
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
