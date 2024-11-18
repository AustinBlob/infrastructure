resource "aws_route53_zone" "primary_domain" {
  name = "austinpgraham.com"

  tags = {
    "Environment" = "prod"
    "App"         = "blog"
  }
}

