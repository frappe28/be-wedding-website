locals {
  s3_origin_id = "fe-chiesa-${var.env}"
}

resource "aws_cloudfront_origin_access_control" "fe_chiesa" {
  name                              = local.s3_origin_id
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "fe_chiesa" {
  comment = "CloudFrontOriginAccessIdentity for ${var.env}-${var.project}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name         = aws_s3_bucket_website_configuration.fe_chiesa.website_endpoint
    origin_id           = local.s3_origin_id
    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "SSLv3",
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment = "cdn chiesa"
  
  aliases = var.env == "prod" ? ["church.fransciswedding.fast-page.org", "www.church.fransciswedding.fast-page.org"] : []

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400 #3600
    max_ttl                = 31536000 #86400
    compress               = true

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IT", "CH"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.env != "prod"
    acm_certificate_arn            = var.env == "prod" ? "arn:aws:acm:us-east-1:992382446823:certificate/dd57ed1a-0e2d-43e3-b456-d930dfa71a8c" : null
    ssl_support_method             = var.env == "prod" ? "sni-only" : null
    minimum_protocol_version       = var.env == "prod" ? "TLSv1.2_2021" : null
  }
}