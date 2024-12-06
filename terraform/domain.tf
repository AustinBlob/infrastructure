data "aws_route53_zone" "webapp_hosted_zone" {
  name         = "austinpgraham.com."
  private_zone = false
}

locals {
  subdomain_name = "*.austinpgraham.com"
}

resource "aws_route53_record" "jira_domain" {
  zone_id = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name    = "jira.austinpgraham.com"
  type    = "CNAME"
  ttl     = 86400

  records = ["austinpgraham.atlassian.net"]
}

resource "aws_acm_certificate" "jira_cert" {
  depends_on        = [aws_route53_record.jira_domain]
  domain_name       = local.subdomain_name
  validation_method = "DNS"
  provider          = aws.us_east_1 # Required by AWS to use with cloudfront

  tags = {
    Environment = local.env
  }

  lifecycle {
    create_before_destroy = true
  }
}
