output "domain-name" {
  value = var.domain_name
}

output "root-domain-name" {
  value = var.root_domain_name
}

output "acm-certificate-arn" {
  value = aws_acm_certificate.acm_certificate.arn
}