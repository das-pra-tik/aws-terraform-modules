data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  common_tags = {
    Name             = "374278-GileadTest"
    Owner            = "374278"
    Environment      = "Test"
    Application      = "Cloud-Infra"
    Create_date_time = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
    Terraform        = "true"
  }
}

resource "aws_instance" "cloud_instance" {
  depends_on                  = [aws_key_pair.ssh_key_pair]
  count                       = var.instance-count
  ami                         = data.aws_ami.ami_id.id
  instance_type               = var.instance-type
  key_name                    = var.key-pair-name
  vpc_security_group_ids      = var.instance-sec-grp-ids
  subnet_id                   = element(var.subnet-ids, count.index)
  associate_public_ip_address = true
  tags                        = local.common_tags
  disable_api_termination     = false
  user_data                   = file(var.USER-DATA)
  monitoring                  = true

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 8
  }

  lifecycle {
    ignore_changes = [tags["Create_date_time"], ami]
  }
  timeouts {
    create = "10m"
  }
}
