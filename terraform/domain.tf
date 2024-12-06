data "aws_route53_zone" "webapp_hosted_zone" {
  name         = "austinpgraham.com."
  private_zone = false
}

locals {
  subdomain_name = "*.austinpgraham.com"
}

resource "aws_acm_certificate" "jira_cert" { # Terrible naming, this is just the subdomain cert.
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

resource "aws_route53_record" "internal_jira_cname" {
  zone_id = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name    = "internal.jira.austinpgraham.com"
  type    = "CNAME"
  ttl     = 86400

  records = ["internal-jira-austinpgrah-39277a4d-ceab-4e95-8f88-d00711743f03.saas.atlassian.com"]
}

resource "aws_route53_record" "internal_jira_cname_hashed" {
  zone_id = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name    = "_a60c10de41cc8af9c358e49900e7f104.internal.jira.austinpgraham.com"
  type    = "CNAME"
  ttl     = 86400

  records = ["internal-jira-austinpgrah-39277a4d-ceab-4e95-8f88-d00711743f03.ssl.atlassian.com"]
}

resource "aws_route53_record" "jira_cname" {
  zone_id = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name    = "jira.austinpgraham.com"
  type    = "CNAME"
  ttl     = 86400

  records = ["jira-austinpgraham-com-26db8f23-d1d3-4320-991c-b34b097331e9.saas.atlassian.com"]
}

resource "aws_route53_record" "jira_cname_hashed" {
  zone_id = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name    = "_9c87640525ffdd6fdee3cb65dc446b36.jira.austinpgraham.com"
  type    = "CNAME"
  ttl     = 86400

  records = ["jira-austinpgraham-com-26db8f23-d1d3-4320-991c-b34b097331e9.ssl.atlassian.com"]
}
