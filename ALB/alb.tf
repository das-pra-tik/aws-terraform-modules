# get details about the route 53 hosted zone
data "aws_route53_zone" "hosted_zone" {
  name         = var.root_domain_name
  private_zone = false
}

####################################################
# Application Load balancer
####################################################
resource "aws_alb" "my_alb" {
  name                             = var.alb_name
  ip_address_type                  = "ipv4"
  load_balancer_type               = "application"
  internal                         = "false"
  subnets                          = var.alb_public_subnets
  security_groups                  = var.alb_sec_groups
  enable_cross_zone_load_balancing = "true"
  enable_deletion_protection       = "false"
  enable_http2                     = "true"
  idle_timeout                     = 400
  drop_invalid_header_fields       = false
  preserve_host_header             = false
  desync_mitigation_mode           = "defensive"
}

####################################################
# Target Group Creation
####################################################
resource "aws_alb_target_group" "alb_tg" {
  name                 = "tg-80"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc-id
  target_type          = "instance"
  deregistration_delay = 60

  health_check {
    enabled             = "true"
    interval            = 10
    protocol            = "HTTP"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/index.html"
    matcher             = "200"
  }
  lifecycle {
    create_before_destroy = true
  }
}
####################################################
# ALB HTTP [80] Listener
####################################################
resource "aws_alb_listener" "alb_listener_http" {
  depends_on        = [aws_alb.my_alb]
  load_balancer_arn = aws_alb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
####################################################
# ALB HTTPS [443] Listener
####################################################
resource "aws_alb_listener" "alb_listener_https" {
  depends_on        = [aws_alb.my_alb]
  load_balancer_arn = aws_alb.my_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg.arn
  }
}
####################################################
# HTTPS [443] Listener Rule
####################################################
resource "aws_alb_listener_rule" "alb_listener_rule" {
  depends_on   = [aws_alb_listener.alb_listener_https]
  listener_arn = aws_alb_listener.alb_listener_https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg.arn
  }
  condition {
    host_header {
      values = ["www.devops-terraform.click"]
    }
  }
}

####################################################
# Target Group Attachment with Instance
####################################################
resource "aws_alb_target_group_attachment" "alb-tg-attachment" {
  count            = length(var.alb_target_ids)
  target_group_arn = aws_alb_target_group.alb_tg.arn
  target_id        = element(tolist(var.alb_target_ids), count.index)
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE DNS RECORD IN ROUTE53 POINTING AT THE LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "load_balancer" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_alb.my_alb.dns_name
    zone_id                = aws_alb.my_alb.zone_id
    evaluate_target_health = true
  }
  weighted_routing_policy {
    weight = var.weight
  }
  set_identifier = var.identifier
}
