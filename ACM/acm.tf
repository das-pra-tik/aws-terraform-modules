# get details about the route 53 hosted zone
data "aws_route53_zone" "r53_hosted_zone" {
  name         = var.root_domain_name
  private_zone = false
}

# request public certificates from the amazon certificate manager.
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# create a CNAME record set in route 53 for domain validation.
# This adds DNS records from the resource above and inputs them into your Route53 host zone
resource "aws_route53_record" "cname_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.r53_hosted_zone.zone_id
}

# validate acm certificates.This validates your ACM certificate with your domain name
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cname_record : record.fqdn]
}