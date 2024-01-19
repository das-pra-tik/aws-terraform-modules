output "instance-ids" {
  value = [for x in aws_instance.cloud_instance : x.id]
}
output "ami-id" {
  value = data.aws_ami.ami_id.image_id
}
output "instance-size" {
  value = var.instance-type
}
