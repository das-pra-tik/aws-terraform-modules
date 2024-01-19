resource "aws_security_group" "ec2-sg" {
  vpc_id = var.vpc-id
  name   = "374278-DynamicSG-EC2"
  dynamic "ingress" {
    for_each = var.ec2-ports
    iterator = port
    content {
      description = "TCP-Port${port.key}"
      from_port   = port.value.port
      to_port     = port.value.port
      protocol    = port.value.protocol
      cidr_blocks = port.value.cidr_blocks
      self        = false
    }
  }
  dynamic "egress" {
    for_each = var.ec2-ports
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    }
  }
}


resource "aws_security_group" "alb-sg" {
  vpc_id = var.vpc-id
  name   = "374278-DynamicSG-ALB"
  dynamic "ingress" {
    for_each = var.alb-ports
    iterator = port
    content {
      description = "TCP-Port${port.key}"
      from_port   = port.value.port
      to_port     = port.value.port
      protocol    = port.value.protocol
      cidr_blocks = port.value.cidr_blocks
      self        = false
    }
  }
  dynamic "egress" {
    for_each = var.alb-ports
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    }
  }
}