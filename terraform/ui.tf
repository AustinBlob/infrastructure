data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  domain_name = "austinpgraham.com"
  env         = "prod"
}

resource "aws_s3_bucket" "webapp_bucket" {
  bucket = "austinblobwebapp"

  tags = {
    Environment = local.env
  }
}

resource "aws_s3_bucket_policy" "webapp_bucket_policy" {
  bucket = aws_s3_bucket.webapp_bucket.id

  depends_on = [aws_cloudfront_distribution.webapp_distributor]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.id}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "arn:aws:cloudfront::${local.account_id}:distribution/${aws_cloudfront_distribution.webapp_distributor.id}"
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_control" "webapp_cloudfront_oac" {
  name                              = aws_s3_bucket.webapp_bucket.bucket
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "webapp_cert" {
  domain_name       = local.domain_name
  validation_method = "DNS"
  provider          = aws.us_east_1 # Required by AWS to use with cloudfront

  tags = {
    Environment = local.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_cache_policy" "webapp_cache_policy" {
  name        = "WebappCachePolicy"
  default_ttl = 3600
  max_ttl     = 86400
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_distribution" "webapp_distributor" {
  depends_on = [aws_acm_certificate.webapp_cert, aws_cloudfront_cache_policy.webapp_cache_policy]

  origin {
    domain_name              = aws_s3_bucket.webapp_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.webapp_cloudfront_oac.id
    origin_id                = aws_s3_bucket.webapp_bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [local.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.webapp_bucket.id

    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = aws_cloudfront_cache_policy.webapp_cache_policy.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags = {
    Environment = local.env
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.webapp_cert.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "webapp_cloudfront_alias" {
  depends_on = [aws_cloudfront_distribution.webapp_distributor]
  zone_id    = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name       = local.domain_name
  type       = "A"
  alias {
    name                   = aws_cloudfront_distribution.webapp_distributor.domain_name
    zone_id                = aws_cloudfront_distribution.webapp_distributor.hosted_zone_id
    evaluate_target_health = true
  }
}
