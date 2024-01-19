variable "instance-ids" {
  type = list(string)
}
variable "vol_count" { type = number }
variable "vol_size" {
  type = list(number)
}
/*
variable "vol_type" {
  type = list(string)
}*/
variable "vol_dev_name" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
/*
variable "ebs_vol_map" {
  type = map(any)
}
variable "ebs_vol_az" {
  type = list(string)
}
*/
//variable "number_of_instances" { type = number }
