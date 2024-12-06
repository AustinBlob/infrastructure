data "aws_route53_zone" "webapp_hosted_zone" {
  name         = "austinpgraham.com."
  private_zone = false
}

resource "aws_route53_record" "jira_domain" {
  zone_id = data.aws_route53_zone.webapp_hosted_zone.zone_id
  name    = "jira.austinpgraham.com"
  type    = "CNAME"
  ttl     = 86400

  records = ["austinpgraham.atlassian.net"]
}
