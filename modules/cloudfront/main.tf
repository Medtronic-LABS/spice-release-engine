locals {
  name = "${var.project}-${var.environment}"

  s3_origin_id  = "s3-${var.s3_bucket_id}"
  alb_origin_id = "alb-${var.alb_domain_name}"

  default_origin_id = var.default_origin == "s3" ? local.s3_origin_id : local.alb_origin_id

  # AWS Managed Cache Policies
  caching_optimized_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  caching_disabled_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

  # AWS Managed Origin Request Policies
  all_viewer_except_host_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

  resolved_cache_policy_id = var.default_cache_policy_id != "" ? var.default_cache_policy_id : (
    var.default_origin == "s3" ? local.caching_optimized_id : local.caching_disabled_id
  )

  resolved_origin_request_policy_id = var.default_origin_request_policy_id != "" ? var.default_origin_request_policy_id : (
    var.default_origin == "alb" ? local.all_viewer_except_host_id : null
  )

  spa_error_responses = var.spa_mode ? [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
  ] : []

  error_responses = length(var.custom_error_responses) > 0 ? var.custom_error_responses : local.spa_error_responses
}

# --- Origin Access Control (S3) ---

resource "aws_cloudfront_origin_access_control" "this" {
  count = var.s3_origin_enabled ? 1 : 0

  name                              = "${local.name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- S3 Bucket Policy for CloudFront OAC ---

data "aws_iam_policy_document" "s3_policy" {
  count = var.s3_origin_enabled ? 1 : 0

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.s3_origin_enabled ? 1 : 0

  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy[0].json
}

# --- CloudFront Distribution ---

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment != "" ? var.comment : "${local.name} distribution"
  default_root_object = var.s3_origin_enabled ? var.default_root_object : null
  price_class         = var.price_class
  aliases             = var.aliases
  web_acl_id          = var.web_acl_id != "" ? var.web_acl_id : null
  tags                = var.tags

  # --- S3 Origin ---
  dynamic "origin" {
    for_each = var.s3_origin_enabled ? [1] : []
    content {
      domain_name              = var.s3_bucket_regional_domain_name
      origin_id                = local.s3_origin_id
      origin_path              = var.s3_origin_path != "" ? var.s3_origin_path : null
      origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
    }
  }

  # --- ALB Origin ---
  dynamic "origin" {
    for_each = var.alb_origin_enabled ? [1] : []
    content {
      domain_name = var.alb_domain_name
      origin_id   = local.alb_origin_id
      origin_path = var.alb_origin_path != "" ? var.alb_origin_path : null
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = var.alb_origin_protocol_policy
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  # --- Default Cache Behavior ---
  default_cache_behavior {
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = local.default_origin_id
    viewer_protocol_policy     = var.viewer_protocol_policy
    compress                   = var.compress
    cache_policy_id            = local.resolved_cache_policy_id
    origin_request_policy_id   = local.resolved_origin_request_policy_id
    response_headers_policy_id = var.default_response_headers_policy_id != "" ? var.default_response_headers_policy_id : null
  }

  # --- Additional Cache Behaviors ---
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern               = ordered_cache_behavior.value.path_pattern
      allowed_methods            = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods             = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD"])
      target_origin_id           = lookup(ordered_cache_behavior.value, "target_origin_id", local.default_origin_id)
      viewer_protocol_policy     = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      compress                   = lookup(ordered_cache_behavior.value, "compress", true)
      cache_policy_id            = lookup(ordered_cache_behavior.value, "cache_policy_id", local.resolved_cache_policy_id)
      origin_request_policy_id   = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)
    }
  }

  # --- Custom Error Responses ---
  dynamic "custom_error_response" {
    for_each = local.error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # --- SSL ---
  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    ssl_support_method             = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.acm_certificate_arn != "" ? var.minimum_protocol_version : "TLSv1"
  }

  # --- Geo Restrictions ---
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }
}
