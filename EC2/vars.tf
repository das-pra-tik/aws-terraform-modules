variable "instance-type" { type = string }
variable "vpc-id" { type = string }
variable "rsa-bits" { type = number }
variable "key-pair-name" { type = string }
variable "USER-DATA" { type = string }
variable "instance-sec-grp-ids" { type = list(string) }
variable "instance-count" { type = number }
variable "subnet-ids" { type = list(string) }
/*variable "az" {
  type = map(any)
}*/
