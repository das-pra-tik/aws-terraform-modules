output "alb_dns_endpoint" {
  description = "The FQDN of the ALB"
  value       = aws_alb.my_alb.dns_name
}
output "alb_zone_id" {
  value = aws_alb.my_alb.zone_id
}
output "alb_tg_arn" {
  value = aws_alb_target_group.alb_tg.arn
}
