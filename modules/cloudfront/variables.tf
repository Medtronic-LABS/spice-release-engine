variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, production)"
  type        = string
}

# --- Domain & SSL ---

variable "aliases" {
  description = "List of CNAMEs (alternate domain names) for the distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront HTTPS"
  type        = string
  default     = ""
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

# --- S3 Origin ---

variable "s3_origin_enabled" {
  description = "Enable S3 as an origin"
  type        = bool
  default     = false
}

variable "s3_bucket_id" {
  description = "S3 bucket name (id) for the origin"
  type        = string
  default     = ""
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  type        = string
  default     = ""
}

variable "s3_origin_path" {
  description = "Optional path prefix for S3 origin"
  type        = string
  default     = ""
}

# --- ALB / Custom Origin ---

variable "alb_origin_enabled" {
  description = "Enable ALB as an origin"
  type        = bool
  default     = false
}

variable "alb_domain_name" {
  description = "ALB DNS name for the custom origin"
  type        = string
  default     = ""
}

variable "alb_origin_protocol_policy" {
  description = "Protocol policy for ALB origin (http-only, https-only, match-viewer)"
  type        = string
  default     = "https-only"
}

variable "alb_origin_path" {
  description = "Optional path prefix for ALB origin"
  type        = string
  default     = ""
}

# --- Cache Behavior ---

variable "default_origin" {
  description = "Which origin to use as default: 's3' or 'alb'"
  type        = string
  default     = "s3"
}

variable "default_cache_policy_id" {
  description = "Managed cache policy ID for the default behavior. Empty uses CachingOptimized for S3 or CachingDisabled for ALB."
  type        = string
  default     = ""
}

variable "default_origin_request_policy_id" {
  description = "Managed origin request policy ID for the default behavior. Empty uses AllViewerExceptHostHeader for ALB."
  type        = string
  default     = ""
}

variable "default_response_headers_policy_id" {
  description = "Managed response headers policy ID"
  type        = string
  default     = ""
}

variable "allowed_methods" {
  description = "HTTP methods allowed for default behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "HTTP methods cached for default behavior"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Enable automatic compression"
  type        = bool
  default     = true
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy (allow-all, https-only, redirect-to-https)"
  type        = string
  default     = "redirect-to-https"
}

# --- Additional Cache Behaviors ---

variable "ordered_cache_behaviors" {
  description = "Additional ordered cache behaviors (path_pattern, target_origin_id, etc.)"
  type        = any
  default     = []
}

# --- SPA / Error Pages ---

variable "default_root_object" {
  description = "Default root object (e.g. index.html)"
  type        = string
  default     = "index.html"
}

variable "custom_error_responses" {
  description = "Custom error responses for SPA routing"
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  default = []
}

variable "spa_mode" {
  description = "Enable SPA mode — routes 403/404 to index.html"
  type        = bool
  default     = false
}

# --- Access & Security ---

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}

variable "geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "web_acl_id" {
  description = "WAFv2 Web ACL ARN to associate with the distribution"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Enable the CloudFront distribution"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
