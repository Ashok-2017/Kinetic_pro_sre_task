resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.origin_name}"

}

resource "aws_cloudfront_distribution" "redirection_distribution" {
  enabled = true
  aliases = ["{var.origin_name}.com", "www.${var.origin_name}.com"]
  
  origin {
    domain_name = "*"
    origin_id = "{var.origin_name}.com"
    
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-onlty,https-only"
      origin_ssl_protocols = ["TLSV1", "TLSV1.1", "TLSV1.2"]
      }

  }

 }

 default_cache_behaviour {
    allowed_methods  = ["HEAD", "GET", "OPTIONS"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "${var.origin_name}.com"
                                               
    forwarded_values {
      query_string = "${var.forward_query_string}"
    
    cookies {
      forward = "{var.forward_cookies}"
    }
  }

  viewer_protocol_policy = "redirect-to-https"
  min_ttl = 0
  default_ttl = 3600
  max_ttl = 86400

 restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    bucket          = "springleaf-s3-access.s3.amazonaws.com"
    prefix          = "cloudfront/${var.origin_name}.com"
  }
}

output "distribution_hosted_zone_id" {
  value = "${aws_cloudfront_distribution.redirection_distribution.hosted_zone_id}"
}
 





