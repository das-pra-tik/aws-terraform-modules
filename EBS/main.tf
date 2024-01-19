# https://stackoverflow.com/questions/56225212/terraform-creating-multiple-ebs-volumes
# https://stackoverflow.com/questions/69470825/attaching-multiple-ebs-volumes-to-each-ec2-instance
# https://developer.hashicorp.com/terraform/language/functions/setproduct 

# Create EBS Data volumes
resource "aws_ebs_volume" "ebs-vol" {
  count             = length(var.instance-ids) * var.vol_count
  availability_zone = element(var.availability_zones, floor(count.index / var.vol_count))
  size              = var.vol_size[count.index % var.vol_count]
  //type              = var.vol_type[count.index % var.vol_count]
  type           = "gp3"
  iops           = "3000"
  throughput     = "125"
  encrypted      = "true"
  final_snapshot = false
}

# Attach EBS Volumes to EC2 instances 
resource "aws_volume_attachment" "ebs-vol-attach" {
  count        = length(var.instance-ids) * var.vol_count
  device_name  = var.vol_dev_name[count.index % var.vol_count]
  instance_id  = element(tolist(var.instance-ids), floor(count.index / var.vol_count))
  volume_id    = aws_ebs_volume.ebs-vol.*.id[count.index]
  force_detach = "true"
  skip_destroy = "false"
}
